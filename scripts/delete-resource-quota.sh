#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

oc delete --filename ./test-target/resource-quota.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
