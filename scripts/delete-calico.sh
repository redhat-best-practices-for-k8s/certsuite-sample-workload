#!/usr/bin/env bash
set -x

# Download the calico YAML and change the image source to quay
curl https://raw.githubusercontent.com/projectcalico/calico/v3.31.1/manifests/calico.yaml |
	sed s/docker.io/quay.io/g >temp-calico.yaml

# Delete calico (not needed but more feature rich - for future use)
oc delete -f temp-calico.yaml
rm temp-calico.yaml
