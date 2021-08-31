mkdir -p ./temp

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

export res=$(oc get namespace $TNF_PARTNER_NAMESPACE 2>&1)
if [[ ${res#Error from server (NotFound):} != ${res} ]]; then
    echo "namespace ${TNF_PARTNER_NAMESPACE} doesn't exists, no reason to delete"
else
    cat ./local-test-infra/namespace.yaml | ./script/mo > ./temp/rendered-namespace.yaml
    oc delete -f ./temp/rendered-namespace.yaml
    rm ./temp/rendered-namespace.yaml
fi