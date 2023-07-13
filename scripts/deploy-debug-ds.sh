#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
export SUPPORT_IMAGE="${SUPPORT_IMAGE:-debug-partner:latest}"
echo "using registry $TNF_PARTNER_REPO"
mkdir -p ./temp
if [ "$ON_DEMAND_DEBUG_PODS" = "false" ]; then
	echo "configuring always-on debug pods"
	NODE_SELECTOR=""
else
	echo "Configuring on-demand debug pods"
	NODE_SELECTOR="
	    nodeSelector:
	    test-network-function.com/node: target"
fi

# shellcheck disable=SC2002 # Useless cat.
cat ./test-partner/debugpartner.yaml | NODE_SELECTOR=$NODE_SELECTOR "$SCRIPT_DIR"/mo >./temp/debugpartner.yaml
oc apply --filename ./temp/debugpartner.yaml
rm ./temp/debugpartner.yaml
