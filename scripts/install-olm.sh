#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
if ! $CERTSUITE_NON_OCP_CLUSTER; then
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
curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.32.0/install.sh -o install.sh
chmod +x install.sh
./install.sh v0.32.0
rm install.sh

# Wait for all OLM pods to be ready
kubectl wait --for=condition=ready pod --all=true -nolm --timeout="$CERTSUITE_DEPLOYMENT_TIMEOUT"
sleep 5
