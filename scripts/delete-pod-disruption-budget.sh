#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete test PDB
mkdir -p ./temp
cat ./test-target/pod-disruption-budget.yaml | APP_1="testdp" APP_2="testss" "$SCRIPT_DIR"/mo > ./temp/rendered-pod-disruption-budget-template.yaml
oc delete --filename ./temp/rendered-pod-disruption-budget-template.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true
rm ./temp/rendered-pod-disruption-budget-template.yaml
