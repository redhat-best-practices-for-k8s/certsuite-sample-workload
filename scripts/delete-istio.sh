#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

ISTIO_VERSION=1.28.2
ISTIO_DIR=istio-$ISTIO_VERSION

# Check if required environment variables are set
if [ -z "$CERTSUITE_EXAMPLE_NAMESPACE" ]; then
	echo "Error: CERTSUITE_EXAMPLE_NAMESPACE is not set. Exiting."
	exit 1
fi

if [ ! -d "$ISTIO_DIR" ]; then
	echo "Downloading Istio $ISTIO_DIR..."
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
fi

# Uninstall Istio
./$ISTIO_DIR/bin/istioctl uninstall -y --purge

# Remove Istio injection label from namespace
if oc get namespace "$CERTSUITE_EXAMPLE_NAMESPACE" &>/dev/null; then
	echo "Removing Istio injection label from namespace $CERTSUITE_EXAMPLE_NAMESPACE..."
	oc label namespace "$CERTSUITE_EXAMPLE_NAMESPACE" istio-injection-
else
	echo "Namespace $CERTSUITE_EXAMPLE_NAMESPACE does not exist. Skipping label removal."
fi

if ! $CERTSUITE_NON_OCP_CLUSTER; then
	echo "Removing SCC from example namespace service accounts..."
	oc adm policy remove-scc-from-group anyuid system:serviceaccounts:"$CERTSUITE_EXAMPLE_NAMESPACE"
	echo "Deleting Istio network attachment definition..."
	oc -n "$CERTSUITE_EXAMPLE_NAMESPACE" delete network-attachment-definition istio-cni || echo "NAD istio-cni not found. Skipping."
fi

# Delete Istio system namespace
if oc get namespace istio-system &>/dev/null; then
	echo "Deleting namespace istio-system..."
	oc delete namespace istio-system
else
	echo "Namespace istio-system does not exist. Skipping deletion."
fi
