#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

"$SCRIPT_DIR"/mo ./test-target/special-resources.yaml >./temp/rendered-test-special-resources.yaml
oc delete --filename ./temp/rendered-test-special-resources.yaml -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true
rm ./temp/rendered-test-special-resources.yaml