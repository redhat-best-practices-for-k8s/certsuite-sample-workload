#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete test deployment
oc delete  statefulsets.apps/test -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true
