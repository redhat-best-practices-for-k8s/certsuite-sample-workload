#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

oc delete --filename ./scripts/operator-ce.yaml --ignore-not-found=true
