mkdir -p ./temp

if [[ -z "${NAMESPACE_TO_GENERATE}" ]]; then
    export NAMESPACE_TO_GENERATE="tnf"
fi

export res=$(oc get namespace $NAMESPACE_TO_GENERATE 2>&1)
if [[ ${res#Error from server (NotFound):} != ${res} ]]; then
    echo "namespace ${NAMESPACE_TO_GENERATE} doesn't exists, no reason to delete"
else
    cat ./local-test-infra/namespace.yaml | ./script/mo > ./temp/rendered-namespace.yaml
    oc delete -f ./temp/rendered-namespace.yaml
    rm ./temp/rendered-namespace.yaml
fi