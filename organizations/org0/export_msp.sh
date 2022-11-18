#!/bin/bash
set -euo pipefail

. scripts/utils.sh

print "Exporting org0 channel MSP"

#
# Prepare a folder structure containing the organization's MSP certificates
# necessary to join the consortium.
#
ORG_DIR=channel-msp/organizations/ordererOrganizations/org0.localho.st

write_pem org0-ca .ca.signcerts $ORG_DIR/msp/cacerts/ca-signcert.pem
write_pem org0-ca .tlsca.signcerts $ORG_DIR/msp/tlscacerts/tlsca-signcert.pem
write_msp_config org0-ca ca-signcert.pem $ORG_DIR/msp


#
# Extract the orderer TLS certificates.  These will be used by osnadmin for
# TLS connections to the orderers when joining orgs to a channel.
#
write_pem org0-orderersnode1 .tls.signcerts $ORG_DIR/orderers/org0-orderersnode1/tls/signcerts/tls-cert.pem
write_pem org0-orderersnode2 .tls.signcerts $ORG_DIR/orderers/org0-orderersnode2/tls/signcerts/tls-cert.pem
write_pem org0-orderersnode3 .tls.signcerts $ORG_DIR/orderers/org0-orderersnode3/tls/signcerts/tls-cert.pem