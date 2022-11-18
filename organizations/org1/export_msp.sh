#!/bin/bash
set -euo pipefail

. scripts/utils.sh

print "Exporting org1 channel MSP"

#
# Prepare a folder structure containing the organization's MSP certificates
# necessary to join the consortium.
#
ORG_MSP_DIR=channel-msp/organizations/peerOrganizations/org1.localho.st/msp

write_pem org1-ca .ca.signcerts $ORG_MSP_DIR/cacerts/ca-signcert.pem
write_pem org1-ca .tlsca.signcerts $ORG_MSP_DIR/tlscacerts/tlsca-signcert.pem
write_msp_config org1-ca ca-signcert.pem $ORG_MSP_DIR