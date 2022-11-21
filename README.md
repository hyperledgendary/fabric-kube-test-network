# Hyperledger Fabric Kubernetes Test Network

Create a 
Hyperledger Fabric [test-network](https://github.com/hyperledger/fabric-samples/tree/main/test-network) 
on [KIND](https://kind.sigs.k8s.io) 
with [fabric-operator](https://github.com/hyperledger-labs/fabric-operator).  

Objective:  provide _crystal clarity_ to Fabric's _MSP_ and certificate structures, 
focusing on the inductive construction of a multi-organization channel.

![Dark Side of the Moon](https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png)
###### (The Dark Side of the Moon [From Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/File:Dark_Side_of_the_Moon.png) )

For best results, start a new shell for each organization in the consortium.  Imagine that each
shell is running commands on behalf of the org's Fabric administrator.


## Usage - TL/DR:

Check dependencies: 
```shell
./scripts/check.sh 
```

Create a KIND kubernetes cluster: 
```shell
just kind 
```

Start the network: 
```shell
just start-network
```

Create `mychannel`:
```shell
just create-channel
```

Install `asset-transfer` chaincode:
```shell
just install-chaincode
```


## Detailed Guide: 

```shell
% just 
Available recipes:
    check                     # Run the check script to validate third party dependencies
    check-network             # Check that all network services are running
    create-channel            # Create a channel and join all orgs to the consortium
    create-genesis-block      # Create the channel genesis block
    enroll org                # Enroll the users for an org
    export-msp org            # Export org MSP certificates to the consortium organizer
    gather-msp                # Export the MSP certificates for all orgs
    inspect-genesis-block     # inspect the genesis block
    install-cc org            # Install a smart contract on all peers in an org
    install-chaincode         # Install a smart contract on all orgs
    join org                  # Join an org to the channel
    join-orgs                 # Join all orgs to the channel
    kind                      # Start a local KIND cluster with nginx ingress
    operator                  # Launch the operator in the target namespace
    show-context msp org peer # Display env for targeting a peer with the Fabric binaries
    start org                 # Start the nodes for an org
    start-network             # Bring up the entire network
    stop-network              # Shut down the test network and remove all certificates
    unkind                    # Shut down the KIND cluster
```

Check dependencies: 
```shell
just check
```

Create a KIND cluster, Nginx ingress, and local container registry:
```shell
just kind
```

Start CAs, peers, and orderers:
```shell
just operator 

just start org0     # run in a separate "org0 admin" terminal 
just start org1     # run in a separate "org1 admin" terminal 
just start org2     # run in a separate "org2 admin" terminal 
```


## mychannel 

- Bootstrap the channel and join the ordering nodes:
```shell
just create-genesis-block   # run in the org0 terminal
just inspect-genesis-block

just join org0
```

- Join peer organizations to the channel: 
```shell
just join org1              # run in the org1 terminal
just join org2              # run in the org2 terminal
```


## Chaincode 

- Install [asset-transfer](https://github.com/hyperledger/fabric-samples/tree/main/full-stack-asset-transfer-guide/contracts/asset-transfer-typescript)
  version [0.1.4](https://github.com/hyperledgendary/full-stack-asset-transfer-guide/releases/tag/v0.1.4) with the
  Kubernetes [chaincode builder](https://github.com/hyperledger-labs/fabric-builder-k8s):
```shell
just install-cc org1
just install-cc org2
```

- Open a new terminal window to run interactive fabric CLI commands as the **org1 admin** (optional):
```shell
export PATH=$PWD/bin:$PATH
source <(just show-context Org1MSP org1 peer1)
```

- Open a new terminal window to run fabric CLI commands as the **org2 admin** (optional):
```shell
export PATH=$PWD/bin:$PATH
source <(just show-context Org2MSP org2 peer1)
```

- Query chaincode:
```shell
peer chaincode query \
  -n asset-transfer \
  -C mychannel \
  -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'     
```


## Gateway Client Application

When the org1 and org2 CAs are created, they include a bootstrap [registration](organizations/org1/org1-ca.yaml#L50-L52) 
and [enrollment](organizations/org1/enroll.sh#L48) of a client identity for use in gateway application development.

If the `just show-context` command has been loaded into the terminal, the peer, orderer, and
CA certificate paths have been loaded into the environment.

In an org admin shell, load the gateway client environment necessary to run the [trader-typescript](https://github.com/hyperledger/fabric-samples/tree/main/full-stack-asset-transfer-guide/applications/trader-typescript) 
sample gateway application:
```shell
export MSP_ID=Org1MSP        
export ORG=org1

# local MSP enrollment folder for the org client user
export USER_MSP_DIR=$PWD/organizations/$ORG/enrollments/${ORG}user/msp

# Path to private key file 
export PRIVATE_KEY=$USER_MSP_DIR/keystore/key.pem

# Path to user certificate file
export CERTIFICATE=$USER_MSP_DIR/signcerts/cert.pem

# Path to CA certificate
export TLS_CERT=$CORE_PEER_TLS_ROOTCERT_FILE

# Gateway endpoint
export ENDPOINT=$CORE_PEER_ADDRESS
```

- Run the gateway client application as `org1user`: 
```shell
# cd (somehow to) fabric-samples/full-stack-asset-transfer-guide/applications/trader-typescript 

npm install
``` 

```shell
# Create a yellow banana token owned by appleman@org1 
npm start create banana bananaman yellow

npm start getAllAssets

# Transfer the banana among users / orgs 
npm start transfer banana appleman Org1MSP

npm start getAllAssets

# Transfer the banana among users / orgs 
npm start transfer banana bananaman Org2MSP

# Error! Which org owns the banana? 
npm start transfer banana bananaman Org1MSP
```


## Teardown

```shell
just stop-network
```
or
```shell
just unkind
```
