#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/local-pod-under-test.yaml | APP="testdp" RESOURCE_TYPE="Deployment" MULTUS_ANNOTATION=$MULTUS_ANNOTATION "$SCRIPT_DIR"/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply --filename ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml

oc wait deployment test -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout="$TNF_DEPLOYMENT_TIMEOUT"
