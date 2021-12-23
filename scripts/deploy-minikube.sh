#!/usr/bin/env bash
set -x
minikube delete

# Minikube configures the Calico CNI to deploy multus 
minikube start --driver=docker --embed-certs --nodes 3 --cni=calico --feature-gates="LocalStorageCapacityIsolation=false"
