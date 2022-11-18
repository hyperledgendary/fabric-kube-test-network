#!/bin/bash
set -euo pipefail

. scripts/utils.sh

ADMIN_USER=org0admin
ADMIN_PASS=org0adminpw


#
# Save all of the organization enrollments in a local folder.
#
ENROLLMENTS_DIR=${PWD}/organizations/org0/enrollments


#
# Before we can work with the CA, extract the CA's TLS certificate and
# store in .pem format for access with client utilities.
#
write_pem org0-ca .tls.cert $ENROLLMENTS_DIR/org0-ca-tls-cert.pem


#
# Enroll the org channel admin
#
# Skip the enrollment if an enrollment was already made for the user.
#
# TODO: refactor this.  It should read something like:
# enroll org0-ca org0admin org0adminpw $ENROLLMENTS_DIR
#
# TODO: refactor the above so that it is also easy to enroll rcaadmin at the TLS CA
# enroll_tls (or something to change /msp -> /tls and call tlsca arg) 
#
if [ -f "$ENROLLMENTS_DIR/$ADMIN_USER/msp/keystore/key.pem" ]
then
  print "$ADMIN_USER has already been enrolled at org0-ca"

else
  print "Enrolling $ADMIN_USER"
  FABRIC_CA_CLIENT_HOME=$ENROLLMENTS_DIR/$ADMIN_USER \
    fabric-ca-client enroll \
      --url https://${ADMIN_USER}:${ADMIN_PASS}@test-network-org0-ca-ca.org0.localho.st \
      --tls.certfiles $ENROLLMENTS_DIR/org0-ca-tls-cert.pem

  # Enrollment creates a key with a dynamic, hashed file name.  Move this to a predictable location
  mv $ENROLLMENTS_DIR/$ADMIN_USER/msp/keystore/*_sk $ENROLLMENTS_DIR/$ADMIN_USER/msp/keystore/key.pem
fi




#
# Enroll the org CA admin (for registering gateway client identities)
#
# todo: enroll the rcaadmin user so that gateway-client users may be constructed.
#
# RCAADMIN_USER=rcaadmin
# RCAADMIN_PASS=rcaadminpw

