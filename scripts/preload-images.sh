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
