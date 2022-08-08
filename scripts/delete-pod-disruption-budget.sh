#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# Delete test PDB
oc delete pdb test-pdb-min -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true
oc delete pdb test-pdb-max -n "${TNF_EXAMPLE_CNF_NAMESPACE}" --ignore-not-found=true
