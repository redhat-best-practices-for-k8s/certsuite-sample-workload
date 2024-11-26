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
	docker.io/library/httpd:2.4.58
	"$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION"
	quay.io/redhat-best-practices-for-k8s/certsuite-sample-workload:latest
	quay.io/testnetworkfunction/debug-partner:latest
	quay.io/testnetworkfunction/cr-scale-operator:latest
	gcr.io/distroless/static:nonroot
	quay.io/calico/node:v3.29.1
	quay.io/testnetworkfunction/nginx-operator-bundle:v0.0.1
	ghcr.io/k8snetworkplumbingwg/multus-cni:snapshot
	registry.access.redhat.com/ubi9/ubi:latest
	registry.access.redhat.com/ubi9/ubi-minimal:latest
	quay.io/operator-framework/configmap-operator-registry:latest
	ghcr.io/k8snetworkplumbingwg/whereabouts:latest
	quay.io/jitesoft/alpine:latest
	registry.k8s.io/coredns/coredns:v1.10.1
)

# Preload images
for image in "${IMAGES_TO_PRELOAD[@]}"; do
	${CONTAINER_CLIENT} pull "$image"
	${CONTAINER_CLIENT} save "$image" -o image.tar && kind load image-archive image.tar && rm image.tar
done
