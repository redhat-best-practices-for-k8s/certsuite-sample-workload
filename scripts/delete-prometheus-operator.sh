#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

oc delete  --filename ./kube-prometheus -n "monitoring" --ignore-not-found=true
