#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
REPO_NAME=crd-operator-scaling
CRD_SCALING_URL=https://github.com/test-network-function/$REPO_NAME.git
rm -rf $REPO_NAME
git clone $CRD_SCALING_URL
## install the operator
cd $REPO_NAME || exit 1
## uninstall the crd
make uninstall
make undeploy ignore-not-found=true
rm -rf $REPO_NAME
