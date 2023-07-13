#!/usr/bin/env bash

# See documentation for more information on network policies:
# https://kubernetes.io/docs/concepts/services-networking/network-policies/

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Apply the default policies "deny-all"
oc apply --filename ./test-target/ingress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
oc apply --filename ./test-target/egress-deny-all-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"

# Render the script with vars
mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/pod-to-pod-np.yaml | TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE "$SCRIPT_DIR"/mo >./temp/rendered-pod-to-pod-np.yaml

# Apply policies to allow pod-to-pod communication (aka make the ping test work)
oc apply --filename ./temp/rendered-pod-to-pod-np.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
rm ./temp/rendered-pod-to-pod-np.yaml
