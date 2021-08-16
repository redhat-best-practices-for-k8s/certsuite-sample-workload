mkdir -p ./temp

if [[ -z "${NAMESPACE_TO_GENERATE}" ]]; then
    export NAMESPACE_TO_GENERATE="tnf"
fi

export res=$(oc get deployment -n $NAMESPACE_TO_GENERATE test 2>&1)
if [[ ${res#Error from server (NotFound)} != ${res} ]] || [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/local-pod-under-test.yaml | ./script/mo > ./temp/rendered-local-pod-under-test-template.yaml
    oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
    rm ./temp/rendered-local-pod-under-test-template.yaml
else
    echo "target pod already exists, no reason to recreate"
fi
sleep 3
oc wait pod -n $NAMESPACE_TO_GENERATE --for=condition=ready -l "app=test" --timeout=30s
