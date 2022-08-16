#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete dualstack service
oc delete  service/test-service-ipv6 -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true

# Delete ipv6 service
oc delete  service/test-service-dualstack -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true
