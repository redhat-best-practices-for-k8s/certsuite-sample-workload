#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Delete performance test suite pods
oc delete pods -l test-network-function.com/feature=performance -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true