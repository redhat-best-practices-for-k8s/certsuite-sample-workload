#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

MULTUS_GIT_URL="https://github.com/k8snetworkplumbingwg/multus-cni.git"
WHEREABOUTS_GIT_URL="https://github.com/k8snetworkplumbingwg/whereabouts"

if $TNF_NON_OCP_CLUSTER
then
  echo "non ocp cluster detected, deploying Multus"

  # Wait for all calico and multus daemonset pods to be running
  oc rollout status daemonset calico-node -n kube-system  --timeout="$TNF_DEPLOYMENT_TIMEOUT"

  rm -rf ./temp
  git clone --depth 1 $MULTUS_GIT_URL  -b v3.9.3 ./temp/multus-cni

  # fix for dimensioning bug
  sed 's/memory: "50Mi"/memory: "100Mi"/g' temp/multus-cni/deployments/multus-daemonset-thick-plugin.yml -i

  # Deploy Multus
  oc apply --filename ./temp/multus-cni/deployments/multus-daemonset-thick-plugin.yml
  
  # Wait for all multus daemonset pods to be running
  oc rollout status daemonset kube-multus-ds -n kube-system  --timeout="$TNF_DEPLOYMENT_TIMEOUT"

  # Install macvlan and other default plugins
  echo "## install CNIs"
  sed 's/alpine/quay.io\/jitesoft\/alpine:latest/g' temp/multus-cni/e2e/cni-install.yml -i
  kubectl create -f temp/multus-cni/e2e/cni-install.yml
  kubectl -n kube-system wait --for=condition=ready -l name="cni-plugins" pod --timeout="$TNF_DEPLOYMENT_TIMEOUT"

  # Install whereabouts at specific released version
  git clone $WHEREABOUTS_GIT_URL --depth 1 -b v0.6.1
  oc apply \
    -f whereabouts/doc/crds/daemonset-install.yaml \
    -f whereabouts/doc/crds/whereabouts.cni.cncf.io_ippools.yaml \
    -f whereabouts/doc/crds/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml \

  rm -rf whereabouts
  # Whereabout does not support dual stack so creating 2 sets of single stack multus interfaces
  create_nets(){
    for (( NUM=0; NUM<MULTUS_IF_NUM; NUM++ ))
    do
      # Creates the network attachment with ptp plugin on partner namespace
      mkdir -p ./temp

      # shellcheck disable=SC2002,SC2001 # Useless cat, echo.
      cat ./config/k8s-cluster/multus.yaml | IP_NUM=$(echo "$2"|sed 's/NUM/'"${NUM}"'/g') NET_NAME_NUM="$NET_NAME-$1-$NUM"  "$SCRIPT_DIR"/mo > ./temp/rendered-multus.yaml
      oc apply --filename ./temp/rendered-multus.yaml
      rm ./temp/rendered-multus.yaml
    done
  }
  # IPv4
  create_nets "ipv4" "192.168.NUM.0/24"
  # IPv6
  create_nets "ipv6" "3ffe:ffff:0:NUM::/64"

  sleep 3
else 
  echo "OCP Cluster detected, Skipping Multus installation"
fi
