#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
if $TNF_NON_OCP_CLUSTER; then
	echo "non ocp cluster detected, applying worker labels on all nodes"
	oc get nodes -oname | xargs -I{} oc label {} node-role.kubernetes.io/worker=worker --overwrite
fi
