#!/usr/bin/env bash
set -x

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

# Cleanup previous deployment if present
operator-sdk cleanup nginx-operator -n $TNF_PARTNER_NAMESPACE

#Wait until pod is deleted
until [[ -z "$(oc get pod cnftest-local-redhat-com-nginx-operator-bundle-v0-0-1 -n $TNF_PARTNER_NAMESPACE 2>/dev/null)" ]]; do sleep 5; done
