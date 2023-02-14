#!/usr/bin/env bash


SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL="https://github.com/test-network-function/crd-operator-scaling.git"
git clone $CRD_SCALING_URL
## install the operator
cd crd-operator-scaling
## install the crd

chmod 777 bin/controller-gen
chmod 777 bin/kustomize

make manifests
make install
make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:latest
oc wait deployment new-pro-controller-manager -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout=240s

make addrole
kubectl apply -f config/samples  --validate=false
