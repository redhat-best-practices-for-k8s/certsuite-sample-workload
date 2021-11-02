#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh


res=`oc version | grep  Server`
if [ -z "$res" ]
then
  echo "minikube detected, deploying Multus, Calico CNI needed in Minikube for this to work"

  rm -rf ./temp
  git clone --depth 1 https://github.com/k8snetworkplumbingwg/multus-cni.git ./temp/multus-cni

  # fix for dimensioning bug
  sed 's/memory: "50Mi"/memory: "100Mi"/g' temp/multus-cni/deployments/multus-daemonset-thick-plugin.yml -i

  # Deploy Multus
  cd ./temp/multus-cni
  cat ./deployments/multus-daemonset-thick-plugin.yml | oc apply -f -
  cd ../..

  # Creates the network attachment on eth0 (bridge)
  mkdir -p ./temp
  cat ./local-test-infra/multus.yaml | $SCRIPT_DIR/mo > ./temp/rendered-multus.yaml
  oc apply -f ./temp/rendered-multus.yaml
  rm ./temp/rendered-multus.yaml
  sleep 3
else 
  echo "Minukube not detected, Skipping Multus installation"
fi
