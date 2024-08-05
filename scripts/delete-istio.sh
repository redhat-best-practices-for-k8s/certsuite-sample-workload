#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
ISTIO_DIR=istio-1.21.2
if [ ! -d "$ISTIO_DIR" ]; then
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.21.2 sh -
fi
./$ISTIO_DIR/bin/istioctl uninstall -y --purge
oc label namespace "$CERTSUITE_EXAMPLE_NAMESPACE" istio-injection-
if ! $CERTSUITE_NON_OCP_CLUSTER; then
	oc adm policy remove-scc-from-group anyuid system:serviceaccounts:"$CERTSUITE_EXAMPLE_NAMESPACE"
	oc -n "$CERTSUITE_EXAMPLE_NAMESPACE" delete network-attachment-definition istio-cni
fi
oc delete namespace istio-system
