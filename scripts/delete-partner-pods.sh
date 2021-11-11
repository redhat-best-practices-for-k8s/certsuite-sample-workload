#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

# Delete partner
oc delete  deployment.apps/tnfpartner -n ${DEFAULT_NAMESPACE}