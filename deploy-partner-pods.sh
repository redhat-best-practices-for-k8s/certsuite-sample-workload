mkdir -p ./temp

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

oc create namespace ${TNF_PARTNER_NAMESPACE}

cat ./local-test-infra/local-partner-deployment.yaml | ./script/mo > ./temp/rendered-partner-template.yaml
oc apply -f ./temp/rendered-partner-template.yaml
rm ./temp/rendered-partner-template.yaml
sleep 3
oc wait pod -n $TNF_PARTNER_NAMESPACE --for=condition=ready -l "app=partner" --timeout=30s
