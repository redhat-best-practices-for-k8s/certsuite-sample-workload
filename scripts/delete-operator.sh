#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Cleanup previous deployment if present
operator-sdk cleanup nginx-operator -n "$CERTSUITE_EXAMPLE_NAMESPACE"

#Wait until pod is deleted
until [[ -z "$(oc get pod "$OPERATOR_REGISTRY_POD_NAME" -n "$CERTSUITE_EXAMPLE_NAMESPACE" 2>/dev/null)" ]]; do sleep 5; done

# Delete nginx-operator in ninginx-ops namespace
echo "Deleting nginx-ingress-operator .."

NGINX_OPERATOR_NS="nginx-ops"
NGINX_APPS_NS="nginx-apps"

CSV=$(oc get subscription nginx-ingress-operator -n "$NGINX_OPERATOR_NS" -o json | jq -r '.status.installedCSV')
oc delete subscription nginx-ingress-operator -n "$NGINX_OPERATOR_NS"
oc delete csv "$CSV" -n "$NGINX_OPERATOR_NS"
oc delete csv "$CSV" -n "$NGINX_APPS_NS"

oc delete namespace "$NGINX_OPERATOR_NS"
oc delete namespace "$NGINX_APPS_NS"
