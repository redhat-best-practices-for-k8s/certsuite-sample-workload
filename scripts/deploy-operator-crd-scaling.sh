#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Skip the install if MacOS
if [[ "$(uname -s)" == "Darwin"* ]]; then
  echo "Skipping operator crd scaling install on MacOS"
  exit 0
fi

# clone the repo
REPO_NAME=crd-operator-scaling
rm -rf $REPO_NAME
git clone "$CRD_SCALING_URL" -b "$CRD_SCALING_TAG" || exit 1

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

# delete the repo after installing
rm -rf "$REPO_NAME"

printf >&2 'Exit by timeout after %d seconds.\n' $((BIT * NUM))
exit 1
