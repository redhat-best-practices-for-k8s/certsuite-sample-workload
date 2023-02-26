#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/pod-disruption-budget.yaml | APP_1="testdp" APP_2="testss" "$SCRIPT_DIR"/mo > ./temp/rendered-pod-disruption-budget-template.yaml
oc apply --filename ./temp/rendered-pod-disruption-budget-template.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
rm ./temp/rendered-pod-disruption-budget-template.yaml
