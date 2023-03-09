#!/usr/bin/env bash
set -x
kind delete cluster

# Kind base with kindnetcni and ipv4/ipv6
kind create cluster --config=config/k8s-cluster/config.yaml

# Download the calico YAML and change the image source to quay
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml |
	sed s/docker.io/quay.io/g >temp-calico.yaml

# Deploy calico (not needed but more feature rich - for future use)
oc create -f temp-calico.yaml
