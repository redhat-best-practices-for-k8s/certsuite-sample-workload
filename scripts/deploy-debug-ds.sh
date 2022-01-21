#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

export SUPPORT_IMAGE="${SUPPORT_IMAGE:-debug-partner:latest}"

echo "using registry $TNF_PARTNER_REPO"
mkdir -p ./temp
cat ./test-partner/debugpartner.yaml | $SCRIPT_DIR/mo > ./temp/debugpartner.yaml
oc apply -f ./temp/debugpartner.yaml
rm ./temp/debugpartner.yaml
