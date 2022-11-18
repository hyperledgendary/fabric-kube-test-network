#!/bin/bash
set -euo pipefail

. scripts/utils.sh

print "Exporting org0 channel MSP"

#
# Prepare a folder structure containing the organization's MSP certificates
# necessary to join the consortium.
#
ORG_MSP_DIR=channel-msp/organizations/ordererOrganizations/org0.localho.st/msp

write_pem org0-ca .ca.signcerts $ORG_MSP_DIR/cacerts/ca-signcert.pem
write_pem org0-ca .tlsca.signcerts $ORG_MSP_DIR/tlscacerts/tlsca-signcert.pem
write_msp_config org0-ca ca-signcert.pem $ORG_MSP_DIR