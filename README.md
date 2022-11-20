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

Ready?
```shell
just check 
```

Set:
```shell
just kind 
```

Go!
```shell
just start-network
```
(or ...) 
```shell
just operator 

just start org0     # run in a separate "org0 admin" terminal 
just start org1     # run in a separate "org1 admin" terminal 
just start org2     # run in a separate "org2 admin" terminal 
```

Double-check the network services:
```shell
just check-network
```

View k8s with [k9s](https://k9scli.io/topics/install/):
```shell
k9s -n test-network
```


## mychannel 

Create mychannel:
```shell
just create-channel
```

(Or ...) 

Create the channel: 
```shell
just create-genesis-block   # run in "org0 admin" terminal
just join org0              # run in "org0 admin" terminal
```

Join peers to the channel: 
```shell
just join org1    # run in "org1 admin" terminal 
just join org2    # run in "org2 admin" terminal 
```


## Chaincode and Gateway Client 


TODO: 
```shell
# just install-chaincode ... 
# just run-gateway-client ... 
```



## Teardown

```shell
just stop-network
```
or
```shell
just unkind
```
