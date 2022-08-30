#!/usr/bin/env bash
set -x
kind delete cluster

# Kind base with kindnetcni and ipv4/ipv6
kind create cluster --config=config/k8s-cluster/config.yaml

# deploy calico (not needed but more feature rich - for future use)
oc create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml

