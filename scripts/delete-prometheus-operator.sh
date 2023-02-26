#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

if ! $TNF_NON_OCP_CLUSTER;then
	echo "OCP cluster detected, skipping prometheus operator deletion"
	exit 0
fi

oc delete  --filename ./kube-prometheus -n "monitoring" --ignore-not-found=true
