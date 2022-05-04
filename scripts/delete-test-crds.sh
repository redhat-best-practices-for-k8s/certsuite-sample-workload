#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete test deployment
oc delete crd crdexamples.test-network-function.com
