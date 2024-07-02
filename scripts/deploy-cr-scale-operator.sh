#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/logging.sh

# Variables for deployment
CR_SCALE_OPERATOR_GIT_REPO="https://github.com/test-network-function/cr-scale-operator.git"
TAG="main"
IMG="quay.io/testnetworkfunction/cr-scale-operator:latest"
CR_SCALE_OPERATOR_DIR=cr-scale-operator

# Clone the repo.
rm -rf ${CR_SCALE_OPERATOR_DIR}
log_info "Cloning cr operator version ${CR_SCALE_OPERATOR_DIR}."
git clone "$CR_SCALE_OPERATOR_GIT_REPO" -b "$TAG" "${CR_SCALE_OPERATOR_DIR}" || exit 1

## Change to checkout folder first.
pushd "${CR_SCALE_OPERATOR_DIR}" || exit 1

# Deploy cr-scale-operator
make deploy IMG=$IMG

# Deploy custom resource
oc apply -f config/samples/cache_v1_memcached.yaml -n "${TNF_EXAMPLE_CNF_NAMESPACE}"

# Check the pods
oc get pods -n "${TNF_EXAMPLE_CNF_NAMESPACE}"

# Return from the checkout folder.
popd || exit 1

log_info "Removing cr operator checkout folder ${CR_SCALE_OPERATOR_DIR}."
rm -rf $CR_SCALE_OPERATOR_DIR
