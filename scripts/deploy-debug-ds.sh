#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh
# check if we're using minikube by looking for kube-apiserver-minikube pod
# if it's minikube, don't install debug partner
res=`oc get pod -A | grep -i kube-apiserver-minikube`
if [[ "$res" -eq "" ]]
then
   oc create -f ./test-partner/debugpartner.yaml
fi