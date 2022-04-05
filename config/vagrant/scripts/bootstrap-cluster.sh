#!/bin/bash

# Download and install Kubebernetes In Docker (Kind):
sudo curl -Lo /usr/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.12.0/kind-linux-amd64
sudo chmod +x /usr/bin/kind

# download openshift client
OPENSHIFT_VERSION="4.7.7"
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