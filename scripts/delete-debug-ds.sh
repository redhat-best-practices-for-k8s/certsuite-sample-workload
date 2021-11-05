#!/usr/bin/env bash

if [[ -n "${TNF_MINIKUBE_CLUSTER}" ]]; then
    echo "minikube detected, skip deleting debug daemonSet"
    exit
fi

oc delete daemonsets.apps/debug -n default
until [[ -z "$(oc get ds debug -n default 2>/dev/null)" ]]; do sleep 5; done
