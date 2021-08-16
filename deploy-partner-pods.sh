mkdir -p ./temp

if [[ -z "${NAMESPACE_TO_GENERATE}" ]]; then
    export NAMESPACE_TO_GENERATE="tnf"
fi

export res=$(oc get namespace $NAMESPACE_TO_GENERATE 2>&1)
if [[ ${res#Error from server (NotFound)} != ${res} ]] || [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/namespace.yaml | ./script/mo > ./temp/rendered-namespace.yaml
    oc apply -f ./temp/rendered-namespace.yaml
    rm ./temp/rendered-namespace.yaml
else
    echo "namespace ${NAMESPACE_TO_GENERATE} already exists, no reason to recreate"
fi

if [[ -n "${TNF_MINIKUBE_ONLY}" ]] && [[ ${TNF_MINIKUBE_ONLY} = "true" ]]; then
    echo "Running with Minikube, no FsDiff pod created"
else
    export res=$(oc get deployment -n $NAMESPACE_TO_GENERATE node-master 2>&1)
    if [[ ${res#Error from server (NotFound)} != ${res} ]] || [[ ${res#No resources found} != ${res} ]]; then
        cat ./local-test-infra/fsdiff-deployment.yaml | ./script/mo > ./temp/rendered-fsdiff-template.yaml
        oc apply -f ./temp/rendered-fsdiff-template.yaml
        rm ./temp/rendered-fsdiff-template.yaml
    else
        echo "fsDiffMasterPod already exists, no reason to recreate"
    fi
    sleep 3
    oc wait pod -n $NAMESPACE_TO_GENERATE --for=condition=ready -l "app=node-master" --timeout=30s
fi

export res=$(oc get deployment -n $NAMESPACE_TO_GENERATE partner 2>&1)
if [[ ${res#Error from server (NotFound)} != ${res} ]] || [[ ${res#No resources found} != ${res} ]]; then
    cat ./local-test-infra/local-partner-deployment.yaml | ./script/mo > ./temp/rendered-partner-template.yaml
    oc apply -f ./temp/rendered-partner-template.yaml
    rm ./temp/rendered-partner-template.yaml
else
    echo "partner pod already exists, no reason to recreate"
fi
sleep 3
oc wait pod -n $NAMESPACE_TO_GENERATE --for=condition=ready -l "app=partner" --timeout=30s