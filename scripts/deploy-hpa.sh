#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Check for existing HPA first
HPA_EXISTS=$(oc get hpa test -n "$TNF_EXAMPLE_CNF_NAMESPACE")
if [ $? -ne 0 ]; then
    # create hpa on the test deployment
    oc autoscale deployment test -n "$TNF_EXAMPLE_CNF_NAMESPACE" --cpu-percent=50 --min=2 --max=3
fi
