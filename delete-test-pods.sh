#!/usr/bin/env bash
set -x

#!/usr/bin/env bash
set -x

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

oc delete  deployment.apps/test -n ${TNF_PARTNER_NAMESPACE}

