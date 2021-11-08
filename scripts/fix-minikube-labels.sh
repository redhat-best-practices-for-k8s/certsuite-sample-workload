#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

if $TNF_NON_OCP_CLUSTER
then
  echo "minikube detected, applying worker labels on all nodes"
  oc get nodes -oname | xargs -I{} oc label  {}  node-role.kubernetes.io/worker=worker --overwrite
fi
