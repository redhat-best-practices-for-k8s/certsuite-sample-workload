#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
# apply the crds and wait for them
git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus   
oc create -f manifests/setup
until oc get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
oc create -f manifests/
oc get pods -A | grep prometheus