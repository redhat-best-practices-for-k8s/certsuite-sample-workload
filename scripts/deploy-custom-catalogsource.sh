#!/usr/bin/env bash
set -x

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

oc create ns "$CUSTOM_CATALOG_NAMESPACE" --dry-run=client --output yaml | oc apply --filename -

# Apply the catalogsource YAML
oc apply --filename ./test-target/custom-catalogsource.yaml --namespace "$CUSTOM_CATALOG_NAMESPACE"

# Patch the custom-catalog service to be IP Family Dual Stack
# This is needed to pass the dual-stack service test
oc patch service custom-catalog --namespace "$CUSTOM_CATALOG_NAMESPACE" --type='json' -p='[{"op": "add", "path": "/spec/ipFamilyPolicy", "value": "PreferDualStack"}]'
oc patch service custom-catalog --namespace "$CUSTOM_CATALOG_NAMESPACE" --type='json' -p='[{"op": "add", "path": "/spec/ipFamilies", "value": ["IPv4", "IPv6"]}]'
