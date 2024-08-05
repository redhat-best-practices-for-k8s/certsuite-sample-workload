#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

CATALOG_CHECK_RETRIES=6 # 30 seconds
while [[ $(oc get packagemanifests 2>/dev/null) == "" && "$CATALOG_CHECK_RETRIES" -gt 0 ]]; do
	echo "waiting for catalog manifests to be available"
	sleep 10
	CATALOG_CHECK_RETRIES=$((CATALOG_CHECK_RETRIES - 1))
	echo $CATALOG_CHECK_RETRIES
done

if [ "$CATALOG_CHECK_RETRIES" -le 0 ]; then
	echo "timed out waiting for the catalog to be available"
	exit 1
fi

# shellcheck disable=SC2143 # Use ! grep -q.
if [[ -z "$(oc get packagemanifests | grep hazelcast 2>/dev/null)" ]]; then
	echo "hazelcast package was not found in the catalog, skipping installation"
	exit 1
fi
echo "hazelcast package found, starting installation"

#check if operator-sdk is installed and install it if needed
if [[ -z "$(which operator-sdk 2>/dev/null)" ]]; then
	echo "operator-sdk executable cannot be found in the path. Will try to install it."
	"$SCRIPT_DIR"/install-operator-sdk.sh
else
	echo "operator-sdk was found in the path, no need to install it"
fi

# Select namespace based on OCP vs Kind
if $CERTSUITE_NON_OCP_CLUSTER; then
	export CATALOG_SOURCE="operatorhubio-catalog"
	export CATALOG_NAMESPACE="olm"
else
	export CATALOG_SOURCE="certified-operators"
	export CATALOG_NAMESPACE="openshift-marketplace"
fi

# Create the operator group
mkdir -p ./temp
CERTSUITE_EXAMPLE_NAMESPACE=$CERTSUITE_EXAMPLE_NAMESPACE "$SCRIPT_DIR"/mo ./test-target/community-operator-group.yaml >./temp/rendered-local-community-operator-group.yaml
oc apply --filename ./temp/rendered-local-community-operator-group.yaml
cat ./temp/rendered-local-community-operator-group.yaml
rm ./temp/rendered-local-community-operator-group.yaml

# Create the Subscription
mkdir -p ./temp
OPERATOR_BASE=$COMMUNITY_OPERATOR_BASE \
	OPERATOR_NAME=$COMMUNITY_OPERATOR_NAME \
	CATALOG_SOURCE=$CATALOG_SOURCE \
	CATALOG_NAMESPACE=$CATALOG_NAMESPACE \
	CERTSUITE_EXAMPLE_NAMESPACE=$CERTSUITE_EXAMPLE_NAMESPACE \
	"$SCRIPT_DIR"/mo ./test-target/community-operator-subscription.yaml >./temp/rendered-local-community-operator-subscription.yaml
oc apply --filename ./temp/rendered-local-community-operator-subscription.yaml
cat ./temp/rendered-local-community-operator-subscription.yaml
rm ./temp/rendered-local-community-operator-subscription.yaml

# Gives time to the resource to come up and approves installation plan for the
# version.
sleep 30
oc patch installplan \
	--namespace "$CERTSUITE_EXAMPLE_NAMESPACE" \
	--type merge \
	--patch '{"spec":{"approved":true}}' \
	"$(
		oc get installplan \
			--namespace "$CERTSUITE_EXAMPLE_NAMESPACE" |
			grep "$COMMUNITY_OPERATOR_NAME" |
			cut -f 1 -d ' '
	)" || {
	printf >&2 'Unable to approve the installation plan.\n'
	exit 1
}
sleep 30
oc wait \
	--for=jsonpath=\{.status.phase\}=Succeeded \
	csv \
	--namespace "$CERTSUITE_EXAMPLE_NAMESPACE" \
	--selector=operators.coreos.com/hazelcast-platform-operator."${CERTSUITE_EXAMPLE_NAMESPACE}" \
	--timeout=600s || {
	printf >&2 'Timed out waiting for the operator to succeed.\n'
	oc get csv --namespace "$CERTSUITE_EXAMPLE_NAMESPACE"
	exit 1
}
sleep 30
oc get csv --namespace "$CERTSUITE_EXAMPLE_NAMESPACE"

# Label the community operator
oc label clusterserviceversions.operators.coreos.com "$COMMUNITY_OPERATOR_NAME" -n "$CERTSUITE_EXAMPLE_NAMESPACE" test-network-function.com/operator=target
