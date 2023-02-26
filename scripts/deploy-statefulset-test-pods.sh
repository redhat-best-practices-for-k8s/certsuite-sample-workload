#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/local-pod-under-test.yaml | APP="testss" RESOURCE_TYPE="StatefulSet" MULTUS_ANNOTATION=$MULTUS_ANNOTATION "$SCRIPT_DIR"/mo > ./temp/rendered-local-statefulset-pod-under-test-template.yaml
oc apply --filename ./temp/rendered-local-statefulset-pod-under-test-template.yaml
rm ./temp/rendered-local-statefulset-pod-under-test-template.yaml
sleep 3

oc wait -l statefulset.kubernetes.io/pod-name=test-0 -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=ready pod --timeout="$TNF_DEPLOYMENT_TIMEOUT"
oc wait -l statefulset.kubernetes.io/pod-name=test-1 -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=ready pod --timeout="$TNF_DEPLOYMENT_TIMEOUT"

# Check for existing HPA first
if ! oc get hpa test -n "$TNF_EXAMPLE_CNF_NAMESPACE"; then
	oc autoscale statefulset test -n "$TNF_EXAMPLE_CNF_NAMESPACE" --cpu-percent=50 --min=2 --max=3
fi
