#!/bin/bash

# Download and install Kubernetes In Docker (Kind):
sudo curl -Lo /usr/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.14.0/kind-linux-amd64
sudo chmod +x /usr/bin/kind

# download the latest openshift client at a certain release level
RELEASE_LEVEL="4.10"
VERSIONS=($(sudo curl -sH 'Accept: application/json' "https://api.openshift.com/api/upgrades_info/v1/graph?channel=stable-${RELEASE_LEVEL}&arch=amd64" | jq -r '.nodes[].version' | sort))
OPENSHIFT_VERSION=${VERSIONS[${#VERSIONS[@]} - 1]}

OC_BIN_TAR="openshift-client-linux.tar.gz"
OC_DL_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp"/${OPENSHIFT_VERSION}/${OC_BIN_TAR}

curl -Lo oc.tar.gz ${OC_DL_URL}
tar -xvf oc.tar.gz
chmod +x oc kubectl
sudo cp oc kubectl /usr/bin/.

# create cluster
cd partner
make rebuild-cluster
make install 