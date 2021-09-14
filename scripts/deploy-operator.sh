#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/operator-env.sh

#check if operator-sdk is installed and install it if needed
if [[ -z "$(which operator-sdk 2>/dev/null)" ]]; then
  echo "operator-sdk executable cannot be found in the path. Will try to install it."
  $SCRIPT_DIR/install-operator-sdk.sh
else
  echo "operator-sdk was found in the path, no need to install it"
fi

# Installing OLM
$SCRIPT_DIR/install-olm.sh

# Create namespace
oc create namespace $TNF_PARTNER_NAMESPACE

$SCRIPT_DIR/delete-operator.sh

# Creates a secret if a pem file exists
$SCRIPT_DIR/create-secret.sh

ADD_SECRET=""
if [[ -n "$(oc get secret -n $TNF_PARTNER_NAMESPACE | awk '{print $1}'| grep $SECRET_NAME)" ]];
then
  ADD_SECRET="--ca-secret-name $SECRET_NAME"
fi

# Deploy the operator bundle
operator-sdk run bundle $OPERATOR_BUNDLE_IMAGE_FULL_NAME -n $TNF_PARTNER_NAMESPACE $ADD_SECRET