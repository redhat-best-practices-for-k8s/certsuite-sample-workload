#!/usr/bin/env bash
set -x

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc delete --filename ./test-target/custom-catalogsource.yaml --namespace "$CUSTOM_CATALOG_NAMESPACE" --ignore-not-found
