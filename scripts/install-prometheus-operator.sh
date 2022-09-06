#!/usr/bin/env bash
set -o errexit
# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
[ -z "$TNF_DEPLOYMENT_TIMEOUT" ] || TNF_DEPLOYMENT_TIMEOUT=30
# Apply the crds and wait for them
git clone https://github.com/prometheus-operator/kube-prometheus.git --depth 1 -b v0.11.0
cd kube-prometheus
oc apply --server-side -f manifests/setup
oc wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring \
    --timeout="$TNF_DEPLOYMENT_TIMEOUT"
oc apply -f manifests/
oc wait \
	--for condition=available \
	--all deployments \
	--namespace=monitoring \
	--timeout="$TNF_DEPLOYMENT_TIMEOUT"
oc get pods -A | grep prometheus
