#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # File not following.
source "$SCRIPT_DIR"/init-env.sh

ISTIO_DIR=istio-1.25.1
ISTIO_PROFILE=demo

if [ ! -d "$ISTIO_DIR" ]; then
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.25.1 sh -
fi
oc create namespace istio-system
if ! $CERTSUITE_NON_OCP_CLUSTER; then
	ISTIO_PROFILE=openshift
	oc adm policy add-scc-to-group anyuid system:serviceaccounts:istio-system
fi
./$ISTIO_DIR/bin/istioctl install --set profile=$ISTIO_PROFILE -y
oc label namespace "$CERTSUITE_EXAMPLE_NAMESPACE" istio-injection=enabled --overwrite
if ! $CERTSUITE_NON_OCP_CLUSTER; then
	oc adm policy add-scc-to-group anyuid system:serviceaccounts:"$CERTSUITE_EXAMPLE_NAMESPACE"
	oc -n "$CERTSUITE_EXAMPLE_NAMESPACE" apply -f ./test-target/nad-istio.yaml
fi
