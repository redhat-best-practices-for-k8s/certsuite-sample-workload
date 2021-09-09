#!/usr/bin/env bash
set -x

# Initialization
DEFAULT_CONTAINER_EXECUTABLE="docker"
CONTAINER_CLIENT="${CONTAINER_EXECUTABLE:-$DEFAULT_CONTAINER_EXECUTABLE}"
HOSTNAME=cnftest-local.redhat.com

# Namespace
if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

# Create namespace
oc create namespace $TNF_PARTNER_NAMESPACE

# Create secret (must be named cert.pem)
cp certs/registry.pem certs/cert.pem
oc delete secret foo-cert-sec -n $TNF_PARTNER_NAMESPACE
oc create secret generic foo-cert-sec --from-file=certs/cert.pem  -n $TNF_PARTNER_NAMESPACE

# Install OLM
operator-sdk olm install

# Load the previously created image
${CONTAINER_CLIENT} load < nginx-operator.tar.gz
${CONTAINER_CLIENT} load < nginx-operator-bundle.tar.gz

# Push it in the registry
${CONTAINER_CLIENT} push $HOSTNAME/nginx-operator-bundle:v0.0.1 
${CONTAINER_CLIENT} push $HOSTNAME/nginx-operator:v0.0.1 

# Cleanup previous deployment if present
operator-sdk cleanup nginx-operator -n $TNF_PARTNER_NAMESPACE

#Wait until pod is deleted
until [[ -z "$(oc get pod cnftest-local-redhat-com-nginx-operator-bundle-v0-0-1 -n $TNF_PARTNER_NAMESPACE 2>/dev/null)" ]]; do sleep 5; done
  
# Deploy the operator bundle
operator-sdk run bundle $HOSTNAME/nginx-operator-bundle:v0.0.1 --ca-secret-name foo-cert-sec -n $TNF_PARTNER_NAMESPACE
