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


#
# Set the environment context for the org2 administrator:
#
export FABRIC_CFG_PATH=${PWD}/channel-config/config
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_MSPCONFIGPATH=$PWD/organizations/org2/enrollments/org2admin/msp
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/channel-config/organizations/peerOrganizations/org2.localho.st/msp/tlscacerts/tlsca-signcert.pem
export CORE_PEER_CLIENT_CONNTIMEOUT=15s
export CORE_PEER_DELIVERYCLIENT_CONNTIMEOUT=15s


function join_peer() {
  local org=$1
  local peer=$2

  print "joining $org $peer to $CHANNEL_NAME"

  CORE_PEER_ADDRESS=${NAMESPACE}-${org}-${peer}-peer.${org}.localho.st:443 \
    peer channel join \
      --blockpath channel-config/${CHANNEL_NAME}_genesis_block.pb
}

join_peer org2 peer1
join_peer org2 peer2
