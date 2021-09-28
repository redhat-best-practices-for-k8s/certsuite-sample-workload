mkdir -p ./temp

export TNF_PARTNER_NAMESPACE="${TNF_PARTNER_NAMESPACE:-tnf}"
export TNF_PARTNER_REPO="${TNF_PARTNER_REPO:-quay.io/testnetworkfunction}"

export res=$(oc get namespace $TNF_PARTNER_NAMESPACE 2>&1)
if [[ ${res#Error from server (NotFound)} != ${res} ]] || [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/namespace.yaml | ./script/mo > ./temp/rendered-namespace.yaml
    oc apply -f ./temp/rendered-namespace.yaml
    rm ./temp/rendered-namespace.yaml
else
    echo "namespace ${TNF_PARTNER_NAMESPACE} already exists, no reason to recreate"
fi

cat ./local-test-infra/local-partner-deployment.yaml | ./script/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3
oc wait pod -n $TNF_PARTNER_NAMESPACE --for=condition=ready -l "app=partner" --timeout=30s
