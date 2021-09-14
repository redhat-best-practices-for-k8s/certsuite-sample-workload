#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/operator-env.sh

mkdir -p ./temp
cat ./local-test-infra/local-partner-deployment.yaml | $SCRIPT_DIR/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3
oc wait pod -n $TNF_PARTNER_NAMESPACE --for=condition=ready -l "app=partner" --timeout=30s
