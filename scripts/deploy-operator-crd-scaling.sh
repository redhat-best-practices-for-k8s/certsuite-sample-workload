#!/usr/bin/env bash


SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL=https://github.com/test-network-function/crd-operator-scaling.git
rm -rf crd-operator-scaling
git clone $CRD_SCALING_URL
## install the operator
cd crd-operator-scaling || exit 1
## install the crd

make manifests
make install
make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:latest
oc wait deployment new-pro-controller-manager -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout=240s

make addrole
kubectl apply -f config/samples --validate=false
