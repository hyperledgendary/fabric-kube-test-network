#!/bin/bash
set -euo pipefail

. scripts/utils.sh

#
# CA
#
print "starting org2 CA"

apply_template organizations/org2/org2-ca.yaml
sleep 5
wait_for ibpca org2-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers.
# This value will be substituted from the environment into the node CRDs.
export CA_CERT=$(connection_profile_cert org2-ca .tls.cert)

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