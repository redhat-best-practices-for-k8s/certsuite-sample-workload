#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

mkdir -p ./temp
cat ./test-partner/partner-deployment.yaml | MULTUS_ANNOTATION=$MULTUS_ANNOTATION $SCRIPT_DIR/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3

oc wait deployment tnfpartner -n default --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT

# Minikube bug needs a scale in/out to reflect the multus changes, bug?
oc scale --replicas=0 deployment tnfpartner -n default
# wait for the pods to be really terminated
kubectl wait  --for=delete pod --selector=app=tnfpartner --timeout=$TNF_DEPLOYMENT_TIMEOUT
# sacle out again
oc scale --replicas=1 deployment tnfpartner -n default
# wait for the deployment to be available
oc wait deployment tnfpartner -n default --for=condition=available --timeout=$TNF_DEPLOYMENT_TIMEOUT
