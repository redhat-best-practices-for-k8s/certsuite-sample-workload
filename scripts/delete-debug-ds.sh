#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete debug daemonset
oc delete  daemonsets.apps/debug -n "${DEFAULT_NAMESPACE}"
until [[ -z "$(oc get ds debug -n "${DEFAULT_NAMESPACE}" 2>/dev/null)" ]]; do sleep 5; done
