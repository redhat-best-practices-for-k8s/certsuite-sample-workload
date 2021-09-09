#!/usr/bin/env bash
set -x

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

oc delete  deployment.apps/partner -n ${TNF_PARTNER_NAMESPACE}