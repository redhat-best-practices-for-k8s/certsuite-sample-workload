#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
mkdir -p ./temp

"$SCRIPT_DIR"/mo ./test-target/test-service-account.yaml >./temp/rendered-test-service-account-template.yaml

APP="testdp" RESOURCE_TYPE="Deployment" MULTUS_ANNOTATION=$MULTUS_ANNOTATION REPLICAS=$REPLICAS "$SCRIPT_DIR"/mo ./test-target/local-pod-under-test.yaml >./temp/rendered-local-pod-under-test-template.yaml
oc apply --filename ./temp/rendered-test-service-account-template.yaml
oc apply --filename ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-test-service-account-template.yaml ./temp/rendered-local-pod-under-test-template.yaml
oc wait deployment test -n "$CERTSUITE_EXAMPLE_NAMESPACE" --for=condition=available --timeout="$CERTSUITE_DEPLOYMENT_TIMEOUT"
