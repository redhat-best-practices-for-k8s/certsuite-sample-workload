#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL=https://github.com/test-network-function/crd-operator-scaling.git
CRD_SCALING_TAG=v0.0.2
rm -rf crd-operator-scaling
git clone $CRD_SCALING_URL -b $CRD_SCALING_TAG || exit 1
## install the operator
cd crd-operator-scaling || exit 1
## install the crd
make manifests
make install
make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:latest
oc wait deployment new-pro-controller-manager -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout=240s
make addrole
kubectl apply -f config/samples --validate=false
BIT=5
NUM=15
for i in $(seq $NUM); do
	printf 'Wait %d seconds for %d times...\n' $BIT "$i"
	sleep $BIT
	kubectl get deployment jack -n "$TNF_EXAMPLE_CNF_NAMESPACE" ||
		continue
	oc wait deployment jack \
		--for=condition=available \
		--namespace "$TNF_EXAMPLE_CNF_NAMESPACE" \
		--timeout=240s
	exit
done
printf >&2 'Exit by timeout after %d seconds.\n' $((BIT * NUM))
exit 1
