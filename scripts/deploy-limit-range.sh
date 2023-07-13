#!/usr/bin/env bash

# See documentation for more information on limit ranges:
# https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/

# Note: This YAML is not installed by default as part of `make install` because we decided to
#        go with ResourceQuota only.  Possibly adding this in later.

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc apply --filename ./test-target/limit-range.yaml --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
