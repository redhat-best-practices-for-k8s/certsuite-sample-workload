#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

#check pem file exists, create a secret with it if present
if [[ -n "$(ls "$SCRIPT_DIR"/certs/registry.pem 2>/dev/null)" ]]; then
	echo 'pem file found, create secret from pem file'
	cp "$SCRIPT_DIR"/certs/registry.pem "$SCRIPT_DIR"/certs/cert.pem
	oc delete secret "$SECRET_NAME" -n "$TNF_EXAMPLE_CNF_NAMESPACE" --ignore-not-found=true
	oc create secret generic "$SECRET_NAME" --from-file="$SCRIPT_DIR"/certs/cert.pem -n "$TNF_EXAMPLE_CNF_NAMESPACE"
else
	echo "No pem file present, skipping secret creation"
fi
