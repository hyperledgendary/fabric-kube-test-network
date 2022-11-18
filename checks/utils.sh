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

SUCCESS="✅"
WARN="⚠️ "

# tests if varname is defined in the env AND it's an existing directory
function must_declare() {
  local varname=$1

  if [[ ${!varname+x} ]]
  then
    printf "\r%s %-30s%s\n" $SUCCESS $varname ${!varname}
  else
    printf "\r%s  %-30s %s\n" $WARN $varname
    EXIT=1
  fi
}

function check() {
  local name=$1
  local message=$2

  printf "🤔 %s" $name

  if $name &>/dev/null ; then
    printf "\r%s %-30s" $SUCCESS $name
  else
    printf "\r%s  %-30s" $WARN $name
    EXIT=1
  fi

  echo $message
}