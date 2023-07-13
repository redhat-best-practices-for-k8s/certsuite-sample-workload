#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Check for existing HPA first
if ! oc get hpa test -n "$TNF_EXAMPLE_CNF_NAMESPACE"; then
	# create hpa on the test deployment
	oc autoscale deployment test -n "$TNF_EXAMPLE_CNF_NAMESPACE" --cpu-percent=50 --min=2 --max=3
fi
