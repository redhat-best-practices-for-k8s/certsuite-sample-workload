#!/usr/bin/env bash

# See documentation for more information on limit ranges:
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc apply --filename ./test-target/resource-quota.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
