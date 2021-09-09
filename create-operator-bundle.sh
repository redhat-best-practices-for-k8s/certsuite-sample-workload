#!/usr/bin/env bash
set -x

#setting sudo
sudo echo "setting sudo root"

# Initialization
DEFAULT_CONTAINER_EXECUTABLE="docker"
CONTAINER_CLIENT="${CONTAINER_EXECUTABLE:-$DEFAULT_CONTAINER_EXECUTABLE}"
HOSTNAME=cnftest-local.redhat.com

# Namespace
if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

# Install operator sdk
## Configure platform
export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
export OS=$(uname | awk '{print tolower($0)}')

## Download executable
export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.11.0
curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}

## Download the auth key
gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E

curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt
curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc
gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc

OUT=$(grep operator-sdk_${OS}_${ARCH} checksums.txt | sha256sum -c -)
echo $OUT
if [ "$OUT"="operator-sdk_linux_amd64: OK" ];
then
  chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
  echo "operator-sdk configured"
else 
  echo "Error: Checksum mismatch, quitting"
  exit 1
fi

# Install OLM
operator-sdk olm install

# create the test operator
rm -rf nginx-operator
mkdir nginx-operator
cd nginx-operator
operator-sdk init --domain cnftest-local.redhat.com --plugins helm

# Create a simple nginx API using Helm’s built-in chart boilerplate (from helm create):
operator-sdk create api --group cnftest --version v0 --kind Nginx

# Logging registry before using
${CONTAINER_CLIENT} logs registry 

# Build and push the operator image. Localhost is used to bypass authntication issues
make docker-build docker-push IMG="$HOSTNAME/nginx-operator:v0.0.1"

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
make bundle IMG="cnftest-local.redhat.com/nginx-operator:v0.0.1"
IMAGE_TAG_BASE=$HOSTNAME/nginx-operator make bundle-build bundle-push

# Save the bundle package
${CONTAINER_CLIENT} save $HOSTNAME/nginx-operator-bundle:v0.0.1 > ../nginx-operator-bundle.tar
${CONTAINER_CLIENT} save $HOSTNAME/nginx-operator:v0.0.1 > ../nginx-operator.tar
gzip -d ../nginx-operator-bundle.tar
gzip -d ../nginx-operator.tar

# Display bundle file location
cd ..
echo "Saved the operator bundle package at: $(pwd)/nginx-operator.tar"