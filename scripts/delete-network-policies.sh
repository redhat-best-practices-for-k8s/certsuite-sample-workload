#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

oc delete --filename ./test-target/ingress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
oc delete --filename ./test-target/egress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
oc delete --filename ./test-target/pod-to-pod-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found
