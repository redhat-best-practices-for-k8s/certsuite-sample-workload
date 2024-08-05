#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Cleanup previous deployment if present
operator-sdk cleanup nginx-operator -n "$CERTSUITE_EXAMPLE_NAMESPACE"

#Wait until pod is deleted
until [[ -z "$(oc get pod "$OPERATOR_REGISTRY_POD_NAME" -n "$CERTSUITE_EXAMPLE_NAMESPACE" 2>/dev/null)" ]]; do sleep 5; done
