#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
oc delete --filename ./test-target/ingress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
oc delete --filename ./test-target/egress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found

# Render the script with vars
mkdir -p ./temp
TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE "$SCRIPT_DIR"/mo ./test-target/pod-to-pod-np.yaml >./temp/rendered-pod-to-pod-np.yaml
oc delete --filename ./temp/rendered-pod-to-pod-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
oc delete --filename ./temp/rendered-pod-to-pod-np.yaml --namespace default --ignore-not-found
rm ./temp/rendered-pod-to-pod-np.yaml
