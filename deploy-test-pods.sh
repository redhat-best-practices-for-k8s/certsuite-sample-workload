mkdir -p ./temp

if [[ -z "${NAMESPACE_TO_GENERATE}" ]]; then
    export NAMESPACE_TO_GENERATE="tnf"
fi


cat ./local-test-infra/local-pod-under-test.yaml | ./script/mo > ./temp/rendered-local-pod-under-test-template.yaml
oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
rm ./temp/rendered-local-pod-under-test-template.yaml
sleep 3
oc wait pod -n $NAMESPACE_TO_GENERATE --for=condition=ready -l "app=test" --timeout=30s
