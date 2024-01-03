#!/bin/bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# check if SKIP_PRELOAD_IMAGES is set to true
if [[ "$SKIP_PRELOAD_IMAGES" == "true" ]]; then
	echo "Skipping image preloading"
	exit 0
fi

# Exit script on error
set -e

# Create array for images to preload
IMAGES_TO_PRELOAD=(
	httpd:2.4.58
	"$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION"
	quay.io/testnetworkfunction/cnf-test-partner:latest
	quay.io/testnetworkfunction/debug-partner:latest
	quay.io/testnetworkfunction/cr-scale-operator:latest
	gcr.io/distroless/static:nonroot
	quay.io/calico/node:v3.27.0
	quay.io/testnetworkfunction/nginx-operator-bundle:v0.0.1
	ghcr.io/k8snetworkplumbingwg/multus-cni:snapshot
	ghcr.io/k8snetworkplumbingwg/multus-cni:snapshot-thick
	registry.access.redhat.com/ubi8/ubi:latest
	registry.access.redhat.com/ubi8/ubi-minimal:latest
	quay.io/operator-framework/configmap-operator-registry:latest
	ghcr.io/k8snetworkplumbingwg/whereabouts:latest
	quay.io/jitesoft/alpine:latest
	registry.k8s.io/coredns/coredns:v1.10.1
)

# Preload images
for image in "${IMAGES_TO_PRELOAD[@]}"; do
	docker pull "$image"
	kind load docker-image "$image"
done
