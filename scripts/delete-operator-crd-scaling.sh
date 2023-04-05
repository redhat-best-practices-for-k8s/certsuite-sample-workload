#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# clone the repo
REPO_NAME=crd-operator-scaling
rm -rf $REPO_NAME
git clone "$CRD_SCALING_URL" -b "$CRD_SCALING_TAG" || exit 1

## install the operator
cd $REPO_NAME || exit 1
## uninstall the crd
make uninstall
make undeploy ignore-not-found=true

# delete the repo after uninstalling
rm -rf $REPO_NAME
