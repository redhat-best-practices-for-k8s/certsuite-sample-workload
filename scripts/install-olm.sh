#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

if ! $TNF_NON_OCP_CLUSTER;then
  echo "Assuming OLM is installed by default with OpenShift, skipping installation"
  exit 0
fi

echo "Installing OLM for non OCP cluster"

#check if operator-sdk is installed and install it if needed
if [[ -z "$(which operator-sdk 2>/dev/null)" ]]; then
  echo "operator-sdk executable cannot be found in the path. Will try to install it."
  "$SCRIPT_DIR"/install-operator-sdk.sh
else
  echo "operator-sdk was found in the path, no need to install it"
fi

# Install OLM
operator-sdk olm uninstall
operator-sdk olm install --version=v0.20.0
# Wait for all OLM pods to be ready
kubectl wait --for=condition=ready pod --all=true -nolm --timeout="$TNF_DEPLOYMENT_TIMEOUT"
sleep 5
