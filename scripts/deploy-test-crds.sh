#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc apply --filename ./test-target/local-crd-under-test.yaml

oc wait crd crdexamples.test-network-function.com --timeout=5s --for=condition=established
