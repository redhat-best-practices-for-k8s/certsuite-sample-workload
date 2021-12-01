#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

mkdir -p ./temp
cat ./test-partner/partner-deployment.yaml | MULTUS_ANNOTATION=$MULTUS_ANNOTATION $SCRIPT_DIR/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3

# adding oc get pods here to refresh the pod list for oc wait, bug ?
oc get pods
oc wait deployment tnfpartner -n default --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT

# Minikube bug needs another scale out?
oc scale --replicas=0 deployment tnfpartner -n default
oc scale --replicas=1 deployment tnfpartner -n default
# adding oc get pods here to refresh the pod list for oc wait, bug ?
oc get pods
oc wait deployment tnfpartner -n default --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT
