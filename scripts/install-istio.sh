#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/init-env.sh
source "$SCRIPT_DIR"/init-env.sh

ISTIO_DIR=istio-1.18.0
ISTIO_PROFILE=demo

if [ ! -d "$ISTIO_DIR" ]; then
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.18.0 sh -
fi

oc create namespace istio-system
if ! $TNF_NON_OCP_CLUSTER; then
    ISTIO_PROFILE=openshift
    oc adm policy add-scc-to-group anyuid system:serviceaccounts:istio-system
fi

./$ISTIO_DIR/bin/istioctl install --set profile=$ISTIO_PROFILE -y
oc label namespace "$TNF_EXAMPLE_CNF_NAMESPACE" istio-injection=enabled --overwrite

if ! $TNF_NON_OCP_CLUSTER; then
    oc adm policy add-scc-to-group anyuid system:serviceaccounts:"$TNF_EXAMPLE_CNF_NAMESPACE"
    oc -n "$TNF_EXAMPLE_CNF_NAMESPACE" create -f ./test-target/nad-istio.yaml
fi
