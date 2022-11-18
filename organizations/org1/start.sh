#!/bin/bash
set -euo pipefail

. scripts/utils.sh

#
# CA
#
print "starting org1 CA"

apply_template organizations/org1/org1-ca.yaml
sleep 5
wait_for ibpca org1-ca

# Retrieve the org CA certificate for the bootstrap enrollment of peers/orderers.
# This value will be substituted from the environment into the node CRDs.
export CA_CERT=$(connection_profile_cert org1-ca .tls.cert)


#
# Network nodes
#
print "starting org1 orderers"

print "starting org1 peers"

apply_template organizations/org1/org1-peer1.yaml
apply_template organizations/org1/org1-peer2.yaml
sleep 5

wait_for ibppeer org1-peer1
wait_for ibppeer org1-peer2