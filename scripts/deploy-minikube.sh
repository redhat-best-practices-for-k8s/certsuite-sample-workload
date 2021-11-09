#!/usr/bin/env bash
set -x
minikube delete

# Minikube configures the Calico CNI to deploy multus 
minikube start --driver=virtualbox --embed-certs --nodes 3 --cni=calico 
