#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

"$SCRIPT_DIR"/mo ./test-target/storage.yaml >./temp/rendered-test-storage.yaml
oc apply --filename ./temp/rendered-test-storage.yaml --namespace "$CERTSUITE_EXAMPLE_NAMESPACE"
rm ./temp/rendered-test-storage.yaml
