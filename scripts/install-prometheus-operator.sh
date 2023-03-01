#!/usr/bin/env bash
set -o errexit
# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

if ! $TNF_NON_OCP_CLUSTER;then
	echo "OCP cluster detected, skipping prometheus operator installation"
	exit 0
fi

# Clear any existing kube-prometheus folders
rm -rf kube-prometheus

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

rm -rf kube-prometheus
