#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Login to the registry
docker login quay.io/testnetworkfunction

# create the test operator
rm -rf nginx-operator
mkdir nginx-operator
cd nginx-operator || exit
operator-sdk init --domain "$REGISTRY_NAME" --plugins helm

# Create a simple nginx API using Helm’s built-in chart boilerplate (from helm create):
operator-sdk create api --group cnftest --version v0 --kind Nginx

# Logging registry before using
${CONTAINER_CLIENT} logs registry 

# Build and push the operator image.
make docker-build docker-push IMG="$OPERATOR_IMAGE_FULL_NAME"

# Configure the operator manifest
mkdir -p config/manifests/bases

# Create configration
cat > config/manifests/bases/nginx-operator.clusterserviceversion.yaml <<-'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: ClusterServiceVersion
metadata:
  annotations:
    alm-examples: '[]'
    capabilities: Basic Install
    test-network-function.com/subscription_name: '["nginx-operator-v0-0-1-sub"]'
  name: nginx-operator.v0.0.0
  namespace: placeholder
  labels:
    test-network-function.com/operator: target
spec:
  apiservicedefinitions: {}
  customresourcedefinitions: {}
  description: cnftest
  displayName: test-operator
  icon:
  - base64data: ""
    mediatype: ""
  install:
    spec:
      deployments: null
    strategy: ""
  installModes:
  - supported: false
    type: OwnNamespace
  - supported: false
    type: SingleNamespace
  - supported: false
    type: MultiNamespace
  - supported: true
    type: AllNamespaces
  keywords:
  - cnftest
  links:
  - name: Nginx Operator
    url: https://nginx-operator.domain
  maintainers:
  - email: deliedit@redhat.com
    name: david
  maturity: alpha
  provider:
    name: redhat
  version: 0.0.0
EOF

# Make and push the operator bundle
make bundle IMG="$OPERATOR_IMAGE_FULL_NAME"
IMAGE_TAG_BASE=$REGISTRY$DIRECTORY$OPERATOR_BUNDLE_BASE_IMAGE make bundle-build bundle-push

# cleanup
cd ..
rm -rf nginx-operator
