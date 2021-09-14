#!/usr/bin/env bash
set -x
minikube delete
minikube start --driver=virtualbox --embed-certs --nodes 3