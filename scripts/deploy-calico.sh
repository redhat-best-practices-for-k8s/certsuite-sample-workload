#!/usr/bin/env bash
set -x

# Download the calico YAML and change the image source to quay
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml |
	sed s/docker.io/quay.io/g >temp-calico.yaml

# Deploy calico (not needed but more feature rich - for future use)
oc create -f temp-calico.yaml
rm temp-calico.yaml
