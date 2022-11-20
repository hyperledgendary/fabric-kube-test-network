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


## Detailed Guide: 

```shell
% just 
Available recipes:
    check                 # Run the check script to validate third party dependencies
    check-network         # Check that all network services are running
    create-genesis-block  # Create the channel genesis block
    enroll org            # Enroll the users for an org
    export-msp org        # Export org MSP certificates to the consortium organizer
    gather-msp            # Export the MSP certificates for all orgs
    inspect-genesis-block # inspect the genesis block
    join org              # Join an org to the channel
    kind                  # Start a local KIND cluster with nginx ingress
    operator              # Launch the operator in the target namespace
    start org             # Start the nodes for an org
    start-network         # Bring up the entire network
    stop-network          # Shut down the test network and remove all certificates
    unkind                # Shut down the KIND cluster
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

```shell
just create-genesis-block   # run in "org0 admin" terminal
just join org0
```

```shell
just join org1              # run in "org1 admin" terminal
just join org2              # run in "org2 admin" terminal
```


## Chaincode and Gateway Client 

TODO: do


## Teardown

```shell
just stop-network
```
or
```shell
just unkind
```
