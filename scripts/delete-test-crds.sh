#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Delete role
oc delete role crdexample-role -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true

# Delete CRD
oc delete crd crdexamples.test-network-function.com --ignore-not-found=true
