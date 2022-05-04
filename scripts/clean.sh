#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete tnf, partner and operator and litmus
./"$SCRIPT_DIR"/delete-partner-pods.sh
./"$SCRIPT_DIR"/delete-test-pods.sh
./"$SCRIPT_DIR"/delete-hpa.sh
./"$SCRIPT_DIR"/delete-test-crds.sh
./"$SCRIPT_DIR"/delete-debug-ds.sh
./"$SCRIPT_DIR"/delete-statefulset-pods.sh
./"$SCRIPT_DIR"/delete-community-operator.sh
./"$SCRIPT_DIR"/delete-litmus-operator.sh
