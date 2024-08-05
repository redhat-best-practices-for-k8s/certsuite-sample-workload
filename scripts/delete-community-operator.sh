#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# delete CSV
oc delete csv "$COMMUNITY_OPERATOR_NAME" -n "$CERTSUITE_EXAMPLE_NAMESPACE" --ignore-not-found=true

# delete operator group
oc delete operatorgroups test-group -n "$CERTSUITE_EXAMPLE_NAMESPACE" --ignore-not-found=true

# delete subscription
oc delete subscriptions test-subscription -n "$CERTSUITE_EXAMPLE_NAMESPACE" --ignore-not-found=true
