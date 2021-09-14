#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/operator-env.sh

# Delete namespace
oc delete namespace ${TNF_PARTNER_NAMESPACE}