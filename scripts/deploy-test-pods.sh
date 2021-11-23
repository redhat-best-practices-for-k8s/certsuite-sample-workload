#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

# Create namespace if it does not exist
oc create namespace ${TNF_EXAMPLE_CNF_NAMESPACE} 2>/dev/null

mkdir -p ./temp
cat ./test-target/local-pod-under-test.yaml | $SCRIPT_DIR/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml
sleep 3

oc wait deployment test -n $TNF_EXAMPLE_CNF_NAMESPACE --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT