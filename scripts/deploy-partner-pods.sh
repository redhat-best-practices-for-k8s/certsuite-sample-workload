#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

mkdir -p ./temp
cat ./local-test-infra/local-partner-deployment.yaml | $SCRIPT_DIR/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3

oc wait deployment tnfpartner -n default --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT
