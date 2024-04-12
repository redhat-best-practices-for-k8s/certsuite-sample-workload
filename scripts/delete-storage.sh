#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/storage.yaml | "$SCRIPT_DIR"/mo >./temp/rendered-test-storage.yaml
oc delete --filename ./temp/rendered-test-storage.yaml -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true
rm ./temp/rendered-test-storage.yaml