#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

export REDHAT_RHEL_REGISTRY="${REDHAT_RHEL_REGISTRY:-registry.redhat.io/rhel8}"
# check if we're using minikube by looking for kube-apiserver-minikube pod
# if it's minikube, don't install debug partner
if $TNF_NON_OCP_CLUSTER
then
  echo "minikube detected, skip installing debug daemonSet"
else
  echo "use registry $REDHAT_RHEL_REGISTRY"
  mkdir -p ./temp
  cat ./test-partner/debugpartner.yaml | $SCRIPT_DIR/mo > ./temp/debugpartner.yaml
  oc create -f ./temp/debugpartner.yaml
  rm ./temp/debugpartner.yaml
fi
