# Kubernetes Test Network

Create a _cloud-native_ [test-network](https://github.com/hyperledger/fabric-samples/tree/main/test-network) on [KIND](https://kind.sigs.k8s.io) with the [Hyperledger Fabric Operator](https://github.com/hyperledger-labs/fabric-operator)  

Objective:  provide _crystal clarity_ to Fabric's multi-org _MSP_ abstraction, focusing on 
the set up of independent organizations working together in a shared consortium.

![Dark Side of the Moon](https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png)
###### (The Dark Side of the Moon [From Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/File:Dark_Side_of_the_Moon.png#filelinks) )

## Usage - TL/DR:

```shell
% just 
Available recipes:
    check      # Run the check script to validate third party dependencies
    clean      # Shut down the test network and remove all certificates
    enroll org # Enroll the users for an org
    kind       # Start a local KIND cluster with nginx and insecure docker registry
    network-up # Bring up the entire network
    operator   # Launch the operator in the target namespace
    start org  # Start the nodes for an org
    unkind     # Shut down the KIND cluster
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
just operator

just start org0
just start org1
just start org2
```

(or...) 
```shell
just start-network
```


Check k8s with [k9s](https://k9scli.io/topics/install/):  
```shell
k9s -n test-network
```



TODO: 
```shell
# just create-channel
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
