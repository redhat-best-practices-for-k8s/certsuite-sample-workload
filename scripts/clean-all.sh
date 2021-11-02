#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

# Delete debug pods
./$SCRIPT_DIR/delete-debug-ds.sh

# Delete namespace
oc delete namespace ${TNF_PARTNER_NAMESPACE}

# Delete test CRDs
$SCRIPT_DIR/delete-test-crds.sh
