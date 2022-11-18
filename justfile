#
# Copyright contributors to the Hyperledgendary Full Stack Asset Transfer project
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

# Main justfile to run all the development scripts
# To install 'just' see https://github.com/casey/just#installation


###############################################################################
#
###############################################################################

# Ensure all properties are exported as shell env-vars
set export

# Use environment variables from the (git-ignored and hidden) .env files
set dotenv-load

# set the current directory, and the location of the test dats
CWDIR := justfile_directory()

_default:
  @just -f {{justfile()}} --list

# Run the check script to validate third party dependencies
check:
  ${CWDIR}/scripts/check.sh


###############################################################################
# Environment and just parameters
###############################################################################

CLUSTER_NAME        := env_var_or_default("TEST_NETWORK_CLUSTER_NAME",      "kind")
NAMESPACE           := env_var_or_default("TEST_NETWORK_NAMESPACE",         "test-network")
OPERATOR_IMAGE      := env_var_or_default("TEST_NETWORK_OPERATOR_IMAGE",    "ghcr.io/hyperledger-labs/fabric-operator:latest-amd64")
FABRIC_VERSION      := env_var_or_default("TEST_NETWORK_FABRIC_VERSION",    "2.4.7")
FABRIC_CA_VERSION   := env_var_or_default("TEST_NETWORK_FABRIC_CA_VERSION", "1.5.5")
CHANNEL_NAME        := env_var_or_default("TEST_NETWORK_CHANNEL_NAME",      "mychannel")


###############################################################################
# KIND / k8s targets
###############################################################################

# Start a local KIND cluster with nginx ingress
kind: unkind
    scripts/kind_with_nginx.sh {{CLUSTER_NAME}}

# Shut down the KIND cluster
unkind:
    #!/usr/bin/env bash
    kind delete cluster --name {{CLUSTER_NAME}}

    if docker inspect kind-registry &>/dev/null; then
        echo "Stopping container registry"
        docker kill kind-registry
        docker rm kind-registry
    fi

# Launch the operator in the target namespace
operator:
    scripts/start_operator.sh

###############################################################################
# Test Network
###############################################################################

# Bring up the entire network
start-network: operator
    just start org0
    just start org1
    just start org2

# Start the nodes for an org
start org:
    #!/usr/bin/env bash
    organizations/{{org}}/start.sh      # start the network service
    organizations/{{org}}/enroll.sh     # enroll CA and org admin users

# Enroll the users for an org
enroll org:
    organizations/{{org}}/enroll.sh

# Shut down the test network and remove all certificates
stop-network:
    #!/usr/bin/env bash
    rm -rf organizations/org0/enrollments && echo "org0 enrollments deleted"
    rm -rf organizations/org1/enrollments && echo "org1 enrollments deleted"
    rm -rf organizations/org2/enrollments && echo "org2 enrollments deleted"
    rm -rf channel-config/organizations   && echo "consortium MSP deleted"
    rm channel-config/{{CHANNEL_NAME}}_genesis_block.pb && echo {{CHANNEL_NAME}} " genesis block deleted"

    kubectl delete ns {{ NAMESPACE }} --ignore-not-found=true

# Check that all network services are running
check-network:
    checks/check-network.sh


###############################################################################
# Channel Construction
###############################################################################

# Export org MSP certificates to the consortium organizer
export-msp org:
    organizations/{{org}}/export_msp.sh

# Export the MSP certificates for all orgs
gather-msp:
    just export-msp org0
    just export-msp org1
    just export-msp org2

# Create the channel genesis block
create-genesis-block: check-network gather-msp
    channel-config/create_genesis_block.sh

# inspect the genesis block
inspect-genesis-block:
    #!/usr/bin/env bash
    configtxgen -inspectBlock channel-config/mychannel_genesis_block.pb | jq
