#!/bin/bash

. scripts/utils.sh

ADMIN_USER=org1admin
ADMIN_PASS=org1adminpw


#
# Save all of the organization enrollments in a local folder.
#
ENROLLMENTS_DIR=${PWD}/organizations/org1/enrollments
mkdir -p $ENROLLMENTS_DIR


#
# Before we can work with the CA, extract the CA's TLS certificate and
# store in .pem format for access with client utilities.
#
ORG_CA_CERT=$(connection_profile_cert org1-ca .tls.cert)
echo $ORG_CA_CERT | base64 -d > $ENROLLMENTS_DIR/org1-ca-tls-cert.pem


#
# Enroll the org channel admin
#
# Skip the enrollment if an enrollment was already made for the user.
#
if [ -f "$ENROLLMENTS_DIR/$ADMIN_USER/msp/keystore/key.pem" ]
then
  print "$ADMIN_USER has already been enrolled at org1-ca"

else
  print "Enrolling $ADMIN_USER"
  FABRIC_CA_CLIENT_HOME=$ENROLLMENTS_DIR/$ADMIN_USER \
    fabric-ca-client enroll \
      --url https://${ADMIN_USER}:${ADMIN_PASS}@test-network-org1-ca-ca.localho.st \
      --tls.certfiles $ENROLLMENTS_DIR/org1-ca-tls-cert.pem

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

