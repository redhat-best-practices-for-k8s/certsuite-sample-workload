#!/usr/bin/env bash
set -o errexit
# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
# Apply the crds and wait for them
git clone https://github.com/prometheus-operator/kube-prometheus.git --depth 1 -b v0.11.0
cd kube-prometheus   
oc create -f manifests/setup
oc get pods -A | grep prometheus