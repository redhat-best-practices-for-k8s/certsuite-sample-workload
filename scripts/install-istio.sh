#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # File not following.
source "$SCRIPT_DIR"/init-env.sh

ISTIO_VERSION=1.28.1
ISTIO_DIR=istio-$ISTIO_VERSION
ISTIO_PROFILE=demo

# Check if required environment variables are set
if [ -z "$CERTSUITE_EXAMPLE_NAMESPACE" ]; then
	echo "Error: CERTSUITE_EXAMPLE_NAMESPACE is not set. Exiting."
	exit 1
fi

if [ ! -d "$ISTIO_DIR" ]; then
	echo "Downloading Istio $ISTIO_DIR..."
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
fi

# Create namespace if it doesn't exist
if ! oc get namespace istio-system &>/dev/null; then
	echo "Creating namespace istio-system..."
	oc create namespace istio-system
fi

if ! $CERTSUITE_NON_OCP_CLUSTER; then
	ISTIO_PROFILE=openshift
	echo "Adding SCC to istio-system service accounts..."
	oc adm policy add-scc-to-group anyuid system:serviceaccounts:istio-system
fi

# Install Istio
./$ISTIO_DIR/bin/istioctl install --set profile=$ISTIO_PROFILE -y

# Label namespace for Istio injection
if ! oc get namespace "$CERTSUITE_EXAMPLE_NAMESPACE" &>/dev/null; then
	echo "Creating namespace $CERTSUITE_EXAMPLE_NAMESPACE..."
	oc create namespace "$CERTSUITE_EXAMPLE_NAMESPACE"
fi
oc label namespace "$CERTSUITE_EXAMPLE_NAMESPACE" istio-injection=enabled --overwrite

if ! $CERTSUITE_NON_OCP_CLUSTER; then
	echo "Adding SCC to example namespace service accounts..."
	oc adm policy add-scc-to-group anyuid system:serviceaccounts:"$CERTSUITE_EXAMPLE_NAMESPACE"
	echo "Applying NAD Istio configuration..."
	oc -n "$CERTSUITE_EXAMPLE_NAMESPACE" apply -f ./test-target/nad-istio.yaml
fi
