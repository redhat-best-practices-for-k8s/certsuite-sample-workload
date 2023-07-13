#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
oc create secret docker-registry redhat-registry-secret \
	--docker-server=registry.redhat.io \
	--docker-username="$LOGIN_REGISTRY" \
	--docker-password="$PASSWORD_REGISTRY" \
	--docker-email=deliedit@redhat.com -n "$TNF_EXAMPLE_CNF_NAMESPACE"
oc create secret docker-registry redhat-connect-registry-secret \
	--docker-server=registry.connect.redhat.com \
	--docker-username="$LOGIN_REGISTRY" \
	--docker-password="$PASSWORD_REGISTRY" \
	--docker-email=deliedit@redhat.com -n "$TNF_EXAMPLE_CNF_NAMESPACE"
