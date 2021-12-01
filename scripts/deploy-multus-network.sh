#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

if $TNF_NON_OCP_CLUSTER
then
  echo "minikube detected, deploying Multus, Calico CNI needed in Minikube for this to work"

  rm -rf ./temp
  git clone --depth 1 https://github.com/k8snetworkplumbingwg/multus-cni.git ./temp/multus-cni

  # fix for dimensioning bug
  sed 's/memory: "50Mi"/memory: "100Mi"/g' temp/multus-cni/deployments/multus-daemonset-thick-plugin.yml -i

  # Deploy Multus
  oc apply -f ./temp/multus-cni/deployments/multus-daemonset-thick-plugin.yml
  
  # Wait for all calico and multus daemonset pods to be running
  oc rollout status daemonset calico-node -n kube-system  --timeout=240s
  oc rollout status daemonset kube-multus-ds -n kube-system  --timeout=240s

  # Creates the network attachment on eth0 (bridge) on partner namespace
  mkdir -p ./temp
  cat ./test-target/multus.yaml | RANGE_START="192.168.1.2" RANGE_END="192.168.1.49" $SCRIPT_DIR/mo > ./temp/rendered-multus.yaml
  oc apply -f ./temp/rendered-multus.yaml
  
  # Creating a network attachment for the default namespace as well
  cat ./test-target/multus.yaml | TNF_EXAMPLE_CNF_NAMESPACE=default RANGE_START="192.168.1.50" RANGE_END="192.168.1.99" $SCRIPT_DIR/mo > ./temp/rendered-multus.yaml
  oc apply -f ./temp/rendered-multus.yaml

  rm ./temp/rendered-multus.yaml
  sleep 3
else 
  echo "Minukube not detected, Skipping Multus installation"
fi
