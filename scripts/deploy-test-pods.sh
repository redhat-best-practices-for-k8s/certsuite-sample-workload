#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

mkdir -p ./temp
cat ./local-test-infra/local-pod-under-test.yaml | $SCRIPT_DIR/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml
sleep 3

oc wait deployment test -n $TNF_PARTNER_NAMESPACE --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT