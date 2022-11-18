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

# All checks run in the workshop root folder
cd "$(dirname "$0")"/..

. checks/utils.sh

EXIT=0

function operator_crds() {
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibpcas.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibpconsoles.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibporderers.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibppeers.ibp.com
}

function operator_deployment() {
  kubectl -n ${NAMESPACE} get deployment fabric-operator
}

# Did it apply the CRDs?
function org0_custom_resources() {
  kubectl -n ${NAMESPACE} get ibpca org0-ca
  kubectl -n ${NAMESPACE} get ibporderer org0-orderersnode1
  kubectl -n ${NAMESPACE} get ibporderer org0-orderersnode2
  kubectl -n ${NAMESPACE} get ibporderer org0-orderersnode3
}

function org1_custom_resources() {
  kubectl -n ${NAMESPACE} get ibpca org1-ca
  kubectl -n ${NAMESPACE} get ibppeer org1-peer1
  kubectl -n ${NAMESPACE} get ibppeer org1-peer2
}

function org2_custom_resources() {
  kubectl -n ${NAMESPACE} get ibpca org2-ca
  kubectl -n ${NAMESPACE} get ibppeer org2-peer1
  kubectl -n ${NAMESPACE} get ibppeer org2-peer2
}

function org0_deployments() {
  kubectl -n ${NAMESPACE} get deployment org0-ca
  kubectl -n ${NAMESPACE} get deployment org0-orderersnode1
  kubectl -n ${NAMESPACE} get deployment org0-orderersnode2
  kubectl -n ${NAMESPACE} get deployment org0-orderersnode3
}

function org1_deployments() {
  kubectl -n ${NAMESPACE} get deployment org1-ca
  kubectl -n ${NAMESPACE} get deployment org1-peer1
  kubectl -n ${NAMESPACE} get deployment org1-peer2 
}

function org2_deployments() {
  kubectl -n ${NAMESPACE} get deployment org2-ca
  kubectl -n ${NAMESPACE} get deployment org2-peer1
  kubectl -n ${NAMESPACE} get deployment org2-peer2
}

# Hit the CAs using the TLS certs, etc.
function org0_cas_ready() {
  curl --fail -s --cacert organizations/org0/enrollments/org0-ca-tls-cert.pem https://$NAMESPACE-org0-ca-ca.org0.localho.st/cainfo
}

function org1_cas_ready() {
  curl --fail -s --cacert organizations/org1/enrollments/org1-ca-tls-cert.pem https://$NAMESPACE-org1-ca-ca.org1.localho.st/cainfo
}

function org2_cas_ready() {
  curl --fail -s --cacert organizations/org2/enrollments/org2-ca-tls-cert.pem https://$NAMESPACE-org2-ca-ca.org2.localho.st/cainfo
}

function channel_msp() {
  find channel-config/organizations
}


check operator_crds         "fabric-operator CRDs have been installed"
check operator_deployment   "fabric-operator is running"

check org0_custom_resources "org0 CAs, Orderers, and Peers have been created"
check org1_custom_resources "org1 CAs, Orderers, and Peers have been created"
check org2_custom_resources "org2 CAs, Orderers, and Peers have been created"

check org0_deployments      "org0 services have been deployed"
check org1_deployments      "org1 services have been deployed"
check org2_deployments      "org2 services have been deployed"

check org0_cas_ready        "org0 CAs are available at ingress"
check org1_cas_ready        "org1 CAs are available at ingress"
check org2_cas_ready        "org2 CAs are available at ingress"

#check channel_msp       "Channel MSP has been exported"

exit $EXIT

