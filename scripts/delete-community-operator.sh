#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# delete CSV
oc delete csv "$COMMUNITY_OPERATOR_NAME" -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true

# delete operator group
oc delete operatorgroups test-group -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true

# delete subscription
oc delete subscriptions test-subscription -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true
