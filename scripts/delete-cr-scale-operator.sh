#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/logging.sh

# Variables for deployment.
CR_SCALE_OPERATOR_GIT_REPO="https://github.com/test-network-function/cr-scale-operator.git"
TAG="main"
CR_SCALE_OPERATOR_DIR=cr-scale-operator

# Clone the repo.
rm -rf ${CR_SCALE_OPERATOR_DIR}
log_info "Cloning crd operator version ${CR_SCALE_OPERATOR_DIR}."
git clone "$CR_SCALE_OPERATOR_GIT_REPO" -b "$TAG" "${CR_SCALE_OPERATOR_DIR}" || exit 1

# Go inside the checkout folder.
cd $CR_SCALE_OPERATOR_DIR || exit 1

# Delete custom resource deploymed earlier.
oc delete -f config/samples/cache_v1_memcached.yaml -n "${CERTSUITE_EXAMPLE_NAMESPACE}"

# Clean up operator
./scripts/cleanup.sh

# Return from the checkout folder.
cd .. || exit 1

# Delete the repo.
rm -rf $CR_SCALE_OPERATOR_DIR
