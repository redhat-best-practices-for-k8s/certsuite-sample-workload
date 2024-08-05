#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Delete test PDB
mkdir -p ./temp
APP_1="testdp" APP_2="testss" "$SCRIPT_DIR"/mo ./test-target/pod-disruption-budget.yaml >./temp/rendered-pod-disruption-budget-template.yaml
oc delete --filename ./temp/rendered-pod-disruption-budget-template.yaml --namespace "$CERTSUITE_EXAMPLE_NAMESPACE" --ignore-not-found=true
rm ./temp/rendered-pod-disruption-budget-template.yaml
