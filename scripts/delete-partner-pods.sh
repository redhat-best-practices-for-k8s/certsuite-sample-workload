#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/operator-env.sh

# Delete partner
oc delete  deployment.apps/partner -n ${TNF_PARTNER_NAMESPACE}