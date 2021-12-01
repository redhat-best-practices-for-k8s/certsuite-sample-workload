#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

$SCRIPT_DIR/create-local-registry.sh
$SCRIPT_DIR/deploy-minikube.sh
$SCRIPT_DIR/deploy-test-pods.sh
$SCRIPT_DIR/deploy-hpa.sh
$SCRIPT_DIR/deploy-partner-pods.sh
$SCRIPT_DIR/create-secret.sh
$SCRIPT_DIR/install-operator-sdk.sh
$SCRIPT_DIR/install-olm.sh
$SCRIPT_DIR/create-operator-bundle.sh
$SCRIPT_DIR/deploy-operator.sh