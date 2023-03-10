#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL=https://github.com/test-network-function/crd-operator-scaling.git
rm -rf crd-operator-scaling
git clone $CRD_SCALING_URL
## install the operator
cd crd-operator-scaling || exit 1
## uninstall the crd
make uninstall
make undeploy ignore-not-found=true