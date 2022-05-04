#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete test deployment
oc delete  deployment.apps/test -n "${TNF_EXAMPLE_CNF_NAMESPACE}"
