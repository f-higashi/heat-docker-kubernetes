#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")

source "$KUBE_ROOT/openrc-default.sh"

echo ${KUBE_ROOT}

source "${KUBE_ROOT}/util.sh"

echo "... calling verify-prereqs" >&2
verify-prereqs

echo "... calling kube-up" >&2
kube-up

echo "... calling validate-cluster" >&2
validate-cluster

echo "... calling configure-kubectl" >&2
configure-kubectl

echo "... checking nodes" >&2
kubectl get nodes

exit 0
