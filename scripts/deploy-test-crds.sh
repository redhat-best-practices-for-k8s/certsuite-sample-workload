#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

oc apply --filename ./test-target/local-crd-under-test.yaml

oc wait crd crdexamples.test-network-function.com --timeout=5s --for=condition=established
