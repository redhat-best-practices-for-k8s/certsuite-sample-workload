if [[ -z "${TNF_PARTNER_NAMESPACE}" ]]; then
    export TNF_PARTNER_NAMESPACE="tnf"
fi

./delete-operator.sh
./delete-partner-pods.sh
./delete-test-pods.sh