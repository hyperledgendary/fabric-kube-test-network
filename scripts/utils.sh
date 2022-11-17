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
