mkdir -p ./temp

if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

oc create namespace ${TNF_PARTNER_NAMESPACE}

cat ./local-test-infra/local-pod-under-test.yaml | ./script/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml
sleep 3
oc wait pod -n $TNF_PARTNER_NAMESPACE --for=condition=ready -l "app=test" --timeout=30s
