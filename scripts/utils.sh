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