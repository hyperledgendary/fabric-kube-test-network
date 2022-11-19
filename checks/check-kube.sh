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


function cluster_info() {
  kubectl cluster-info &>/dev/null
}

function nginx() {
  kubectl -n ingress-nginx get all  &>/dev/null
  kubectl -n ingress-nginx get deployment.apps/ingress-nginx-controller  &>/dev/null
  curl http://${WORKSHOP_INGRESS_DOMAIN} &>/dev/null
  curl --insecure https://${WORKSHOP_INGRESS_DOMAIN}:443   &>/dev/null
}

function container_registry() {
  curl --fail http://${WORKSHOP_INGRESS_DOMAIN}:5000/v2/_catalog &>/dev/null
}


must_declare WORKSHOP_INGRESS_DOMAIN
must_declare WORKSHOP_NAMESPACE

check cluster_info        "k8s API controller is running"
check nginx               "Nginx ingress is running at https://${WORKSHOP_INGRESS_DOMAIN}"

if [ x"${WORKSHOP_CLUSTER_RUNTIME}" == x"kind" ]; then
  check container_registry  "Container registry is running at ${WORKSHOP_INGRESS_DOMAIN}:5000"
fi

exit $EXIT

