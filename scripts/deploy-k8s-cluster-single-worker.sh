#!/usr/bin/env bash
set -x

# Kind base with kindnetcni and ipv4/ipv6
kind create cluster --config=config/k8s-cluster/single-worker.yaml
