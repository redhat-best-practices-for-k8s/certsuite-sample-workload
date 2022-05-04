#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Cleanup previous deployment if present
operator-sdk cleanup nginx-operator -n "$TNF_EXAMPLE_CNF_NAMESPACE"

#Wait until pod is deleted
until [[ -z "$(oc get pod "$OPERATOR_REGISTRY_POD_NAME" -n "$TNF_EXAMPLE_CNF_NAMESPACE" 2>/dev/null)" ]]; do sleep 5; done
