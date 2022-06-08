#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete the hpa 
oc delete hpa test -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true
