#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/operator-env.sh

# Delete test deployment
oc delete  deployment.apps/test -n ${TNF_PARTNER_NAMESPACE}

