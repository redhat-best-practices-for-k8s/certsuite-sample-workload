#!/usr/bin/env bash


SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL="https://github.com/test-network-function/crd-operator-scaling.git"
git clone $CRD_SCALING_URL
## install the operator
cd crd-operator-scaling
## install the crd
uname -a
file bin/controller-gen
file bin/kustomize
chmod +x bin/controller-gen
chmod +x bin/kustomize
make manifests
make install
make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:latest
make addrole
kubectl apply -f config/samples  --validate=false
