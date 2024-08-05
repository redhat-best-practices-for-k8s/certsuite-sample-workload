#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc delete --filename ./test-target/resource-quota.yaml --namespace "$CERTSUITE_EXAMPLE_NAMESPACE" --ignore-not-found
