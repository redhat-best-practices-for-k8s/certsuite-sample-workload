#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

#check if operator-sdk is installed and install it if needed
if [[ -z "$(which operator-sdk 2>/dev/null)" ]]; then
  echo "operator-sdk executable cannot be found in the path. Will try to install it."
  $SCRIPT_DIR/install-operator-sdk.sh
else
  echo "operator-sdk was found in the path, no need to install it"
fi

# Select namespace based on OCP vs Kind
if $TNF_NON_OCP_CLUSTER
then
	export CATALOG_SOURCE="operatorhubio-catalog"
	export CATALOG_NAMESPACE="olm"
else
    export CATALOG_SOURCE="certified-operators"
	export CATALOG_NAMESPACE="openshift-marketplace"
fi

# Create the operator group
mkdir -p ./temp
cat ./test-target/community-operator-group.yaml | TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE $SCRIPT_DIR/mo > ./temp/rendered-local-community-operator-group.yaml
oc apply -f ./temp/rendered-local-community-operator-group.yaml
rm ./temp/rendered-local-community-operator-group.yaml

# Create the Subscription
mkdir -p ./temp
cat ./test-target/community-operator-subscription.yaml | OPERATOR_NAME=$COMMUNITY_OPERATOR_BASE CATALOG_SOURCE=$CATALOG_SOURCE CATALOG_NAMESPACE=$CATALOG_NAMESPACE TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE $SCRIPT_DIR/mo > ./temp/rendered-local-community-operator-subscription.yaml
oc apply -f ./temp/rendered-local-community-operator-subscription.yaml
rm ./temp/rendered-local-community-operator-subscription.yaml


CSV_CHECK_RETRIES=24 # 240 seconds
while [[ $(oc get csv -n $TNF_EXAMPLE_CNF_NAMESPACE $COMMUNITY_OPERATOR_NAME -o go-template="{{.status.phase}}") != "Succeeded" && "$CSV_CHECK_RETRIES" -gt 0 ]]; do
	echo "waiting for $COMMUNITY_OPERATOR_NAME installation to succeed"
	sleep 10
	CSV_CHECK_RETRIES=$(($CSV_CHECK_RETRIES-1))
	oc get pods -n $TNF_EXAMPLE_CNF_NAMESPACE
	oc get sa -n $TNF_EXAMPLE_CNF_NAMESPACE
	echo $CSV_CHECK_RETRIES
done

if [ "$CSV_CHECK_RETRIES" -le 0  ]; then
	echo "timed out waiting for the operator to succeed"
	oc get csv -n $TNF_EXAMPLE_CNF_NAMESPACE
	exit 1
fi

oc get csv -n $TNF_EXAMPLE_CNF_NAMESPACE

# Label the community operator
oc label clusterserviceversions.operators.coreos.com $COMMUNITY_OPERATOR_NAME -n $TNF_EXAMPLE_CNF_NAMESPACE test-network-function.com/operator=target

# For the old repo only, add an annotation to identify the subscription
oc annotate csv $COMMUNITY_OPERATOR_NAME test-network-function.com/subscription_name='["test-subscription"]' --overwrite  -ntnf