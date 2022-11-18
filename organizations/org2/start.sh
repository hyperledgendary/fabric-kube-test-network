#!/bin/bash

. scripts/utils.sh

# KISS: No scripting.  Just bring up org2 nodes.

#
# CA
#
print "starting org2 CA"

apply_template organizations/org2/org2-ca.yaml
sleep 5
wait_for ibpca org2-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers
export CA_CERT=$(kubectl -n ${NAMESPACE} get cm/org2-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)


#
# Network nodes
#
print "starting org2 orderers"

print "starting org2 peers"

apply_template organizations/org2/org2-peer1.yaml
apply_template organizations/org2/org2-peer2.yaml
sleep 5

wait_for ibppeer org2-peer1
wait_for ibppeer org2-peer2