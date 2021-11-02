#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

res=`oc version | grep  Server`
if [ -z "$res" ]
then
  echo "minikube detected, applying worker labels on all nodes"
  oc get nodes -oname | xargs -I{} oc label  {}  node-role.kubernetes.io/worker=worker --overwrite
fi
