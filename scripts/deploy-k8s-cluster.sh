#!/usr/bin/env bash
set -x
kind delete cluster

# Kind base with kindnetcni and ipv4/ipv6
kind create cluster --config=config/k8s-cluster/config.yaml

# deploy calico (not needed but more feature rich - for future use)
oc apply -f ./config/k8s-cluster/calico.yaml
