#!/usr/bin/env bash
#
# Copyright contributors to the Hyperledgendary Kubernetes Test Network project
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# 	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -euo pipefail
. scripts/utils.sh

ADMIN_USER=org1admin
ADMIN_PASS=org1adminpw


#
# Save all of the organization enrollments in a local folder.
#
ENROLLMENTS_DIR=${PWD}/organizations/org1/enrollments


#
# Before we can work with the CA, extract the CA's TLS certificate and
# store in .pem format for access with client utilities.
#
write_pem org1-ca .tls.cert $ENROLLMENTS_DIR/org1-ca-tls-cert.pem


#
# Enroll the org channel admin
#
# Skip the enrollment if an enrollment was already made for the user.
#
# TODO: refactor this.  It should read something like:
# enroll org1-ca org1admin org1adminpw $ENROLLMENTS_DIR
#
# TODO: refactor the above so that it is also easy to enroll rcaadmin at the TLS CA
# enroll_tls (or something to change /msp -> /tls and call tlsca arg) 
#
if [ -f "$ENROLLMENTS_DIR/$ADMIN_USER/msp/keystore/key.pem" ]
then
  print "$ADMIN_USER has already been enrolled at org1-ca"

else
  print "Enrolling $ADMIN_USER"
  FABRIC_CA_CLIENT_HOME=$ENROLLMENTS_DIR/$ADMIN_USER \
    fabric-ca-client enroll \
      --url https://${ADMIN_USER}:${ADMIN_PASS}@test-network-org1-ca-ca.org1.localho.st \
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

