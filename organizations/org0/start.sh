#!/bin/bash

. scripts/utils.sh

# KISS: No scripting.  Just bring up org0 nodes.

#
# CA
#
print "starting org0 CA"

apply_template organizations/org0/org0-ca.yaml
sleep 5
wait_for ibpca org0-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers
export CA_CERT=$(kubectl -n ${NAMESPACE} get cm/org0-ca-connection-profile -o json | jq -r .binaryData.\"profile.json\" | base64 -d | jq -r .tls.cert)




#
# Network nodes
#
print "starting org0 orderers"
apply_template organizations/org0/org0-orderers.yaml
sleep 5

wait_for ibporderer org0-orderersnode1
wait_for ibporderer org0-orderersnode2
wait_for ibporderer org0-orderersnode3

print "starting org0 peers"

