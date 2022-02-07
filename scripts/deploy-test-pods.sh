#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh


mkdir -p ./temp
cat ./test-target/local-pod-under-test.yaml | RESOURCE_TYPE="Deployment" MULTUS_ANNOTATION=$MULTUS_ANNOTATION $SCRIPT_DIR/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml

oc wait deployment test -n $TNF_EXAMPLE_CNF_NAMESPACE --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT
