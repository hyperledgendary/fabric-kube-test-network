#!/bin/bash
set -euo pipefail

. scripts/utils.sh

print "Exporting org2 channel MSP"

#
# Prepare a folder structure containing the organization's MSP certificates
# necessary to join the consortium.
#
ORG_MSP_DIR=channel-msp/organizations/peerOrganizations/org2.localho.st/msp

write_pem org2-ca .ca.signcerts $ORG_MSP_DIR/cacerts/ca-signcert.pem
write_pem org2-ca .tlsca.signcerts $ORG_MSP_DIR/tlscacerts/tlsca-signcert.pem
write_msp_config org2-ca ca-signcert.pem $ORG_MSP_DIR