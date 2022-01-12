#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

# Install OLM
operator-sdk olm uninstall
operator-sdk olm install --version=v0.18.3
# Wait for all OLM pods to be ready
kubectl wait --for=condition=ready pod --all=true -nolm --timeout=$TNF_DEPLOYMENT_TIMEOUT
sleep 5s
