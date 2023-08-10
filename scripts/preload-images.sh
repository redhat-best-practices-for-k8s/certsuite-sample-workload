#!/bin/bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Exit script on error
set -e

# Preload httpd from QE
HTTPD_IMAGE=httpd:2.4.57
docker pull $HTTPD_IMAGE
kind load docker-image $HTTPD_IMAGE

# Preload hazelcast-platform-operator
docker pull "$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION"
kind load docker-image "$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION"

# Preload test-partner image since we use that for testing
PARTNER_IMAGE=quay.io/testnetworkfunction/cnf-test-partner:latest
docker pull $PARTNER_IMAGE
kind load docker-image $PARTNER_IMAGE

# Preload debug-partner image for the daemonset
DEBUG_PARTNER_IMAGE=quay.io/testnetworkfunction/debug-partner:latest
docker pull $DEBUG_PARTNER_IMAGE
kind load docker-image $DEBUG_PARTNER_IMAGE

# Preload crd-operator-scaling image
CRD_SCALING_IMAGE=quay.io/testnetworkfunction/crd-operator-scaling:${CRD_SCALING_TAG}
docker pull "$CRD_SCALING_IMAGE"
kind load docker-image "$CRD_SCALING_IMAGE"
