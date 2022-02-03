#!/bin/bash

# Download and install Kubebernetes In Docker (Kind):
sudo curl -Lo /usr/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64
sudo chmod +x /usr/bin/kind

# download openshift client
curl -Lo oc.tar.gz https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -xvf oc.tar.gz --strip-components 1
sudo cp oc kubectl /usr/bin/.

# create cluster
cd partner
make rebuild-cluster
make install 