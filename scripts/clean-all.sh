#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Delete namespace
oc delete namespace "${CERTSUITE_EXAMPLE_NAMESPACE}" --ignore-not-found=true

# Delete test CRDs
"$SCRIPT_DIR"/delete-test-crds.sh
