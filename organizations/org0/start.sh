#!/bin/bash
set -euo pipefail

. scripts/utils.sh

#
# CA
#
print "starting org0 CA"

apply_template organizations/org0/org0-ca.yaml
sleep 5
wait_for ibpca org0-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers.
# This value will be substituted from the environment into the node CRDs.
export CA_CERT=$(connection_profile_cert org0-ca .tls.cert)


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

