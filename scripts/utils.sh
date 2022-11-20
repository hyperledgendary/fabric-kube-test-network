#!/bin/bash

function print() {
	GREEN='\033[0;32m'
  NC='\033[0m'
  echo
	echo -e "${GREEN}${1}${NC}"
}

function wait_for() {
  local type=$1
  local name=$2

  kubectl -n ${NAMESPACE} wait $type $name --for jsonpath='{.status.type}'=Deployed --timeout=3m
  kubectl -n ${NAMESPACE} rollout status deploy $name
}

function apply_template() {
  local template=$1
  cat ${template} | envsubst | kubectl -n ${NAMESPACE} apply -f -
}

# Read a certificate by name from a node connection-profile config map.
function connection_profile_cert() {
  local node=$1
  local path=$2

  kubectl -n ${NAMESPACE} get cm/${node}-connection-profile -o json \
    | jq -r .binaryData.\"profile.json\" \
    | base64 -d \
    | jq -r ${path}
}

# Extract, decode, and save a certificate in .pem format to a local file
function write_pem() {
  local node=$1
  local jq_path=$2
  local to_file=$3

  mkdir -p $(dirname $to_file)

  echo $(connection_profile_cert $node $jq_path) | base64 -d >& $to_file
}

# create an enrollment MSP config.yaml
function write_msp_config() {
  local ca_name=$1
  local ca_cert_name=$2
  local msp_dir=$3

  cat << EOF > ${msp_dir}/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${ca_cert_name}
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${ca_cert_name}
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${ca_cert_name}
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${ca_cert_name}
    OrganizationalUnitIdentifier: orderer
EOF
}



# Enroll a user at an org CA.
function enroll() {
  do_enroll msp ca $@
}

# Enroll a user at an org TLS CA
function enroll_tls() {
  do_enroll tls tlsca $@
}

function do_enroll() {
  local msp_type=$1
  local caname=$2
  local org=$3
  local user=$4
  local pazz=$5

  # Skip the enrollment if a previous enrollment key exists.
  local user_dir=$ENROLLMENTS_DIR/$user
  local user_key=$user_dir/$msp_type/keystore/key.pem

  if [ -f "$user_key" ]; then
    print "$user has already been enrolled at $org $caname"
    return
  fi


  print "enrolling $org $caname $user"
  local ca_url=https://${user}:${pazz}@${NAMESPACE}-${org}-ca-ca.${org}.localho.st
  local tls_certfile=$ENROLLMENTS_DIR/${org}-ca-tls-cert.pem

#  FABRIC_CA_CLIENT_HOME=$user_dir \
    fabric-ca-client enroll \
      --url           $ca_url \
      --tls.certfiles $tls_certfile \
      --mspdir $user_dir/$msp_type \
      --caname $caname

  # Enrollment creates a key with a dynamic, hashed file name.  Move this to a predictable location
  mv $user_dir/$msp_type/keystore/*_sk $user_key
}