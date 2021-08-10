mkdir -p ./temp

if [[ -z "${NAMESPACE_TO_GENERATE}" ]]; then
    export NAMESPACE_TO_GENERATE="tnf"
fi

export res=$(oc get namespace $NAMESPACE_TO_GENERATE 2>&1)
if [[ ${res#Error from server (NotFound):} != ${res} ]]; then
    cat ./local-test-infra/namespace.yaml | ./script/mo > ./temp/rendered-namespace.yaml
    oc apply -f ./temp/rendered-namespace.yaml
    rm ./temp/rendered-namespace.yaml
else
    echo "namespace ${NAMESPACE_TO_GENERATE} already exists, no reason to recreate"
fi

export res=$(oc get pod -n $NAMESPACE_TO_GENERATE -l test-network-function.com/generic=fs_diff_master 2>&1)
if [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/fsdiff-pod.yaml | ./script/mo > ./temp/rendered-fsdiff-template.yaml
    oc apply -f ./temp/rendered-fsdiff-template.yaml
    rm ./temp/rendered-fsdiff-template.yaml
else
    echo "fsDiffMasterPod already exists, no reason to recreate"
fi

export res=$(oc get pod -n $NAMESPACE_TO_GENERATE -l test-network-function.com/generic=target 2>&1)
if [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/local-pod-under-test.yaml | ./script/mo > ./temp/rendered-local-pod-under-test-template.yaml
    oc apply -f ./temp/rendered-local-pod-under-test-template.yaml
    rm ./temp/rendered-local-pod-under-test-template.yaml
else
    echo "partner pod already exists, no reason to recreate"
fi

export res=$(oc get pod -n $NAMESPACE_TO_GENERATE -l test-network-function.com/generic=orchestrator 2>&1)
if [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/local-partner-pod.yaml | ./script/mo > ./temp/rendered-partner-template.yaml
    oc apply -f ./temp/rendered-partner-template.yaml
    rm ./temp/rendered-partner-template.yaml
else
    echo "partner pod already exists, no reason to recreate"
fi