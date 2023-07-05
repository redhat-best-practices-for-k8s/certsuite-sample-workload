#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

CATALOG_CHECK_RETRIES=6 # 30 seconds
while [[ $(oc get packagemanifests 2>/dev/null) == "" && "$CATALOG_CHECK_RETRIES" -gt 0 ]]; do
	echo "waiting for catalog manifests to be available"
	sleep 10
	CATALOG_CHECK_RETRIES=$((CATALOG_CHECK_RETRIES-1))
	echo $CATALOG_CHECK_RETRIES
done

if [ "$CATALOG_CHECK_RETRIES" -le 0  ]; then
	echo "timed out waiting for the catalog to be available"
	exit 1
fi

# shellcheck disable=SC2143 # Use ! grep -q.
if [[ -z "$(oc get packagemanifests | grep hazelcast 2>/dev/null)" ]]; then
	echo "hazelcast package was not found in the catalog, skipping installation"
	exit 0
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
if $TNF_NON_OCP_CLUSTER
then
	export CATALOG_SOURCE="operatorhubio-catalog"
	export CATALOG_NAMESPACE="olm"
else
	export CATALOG_SOURCE="certified-operators"
	export CATALOG_NAMESPACE="openshift-marketplace"
fi

# Pre-pull the image for the operator
docker pull "$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION"
docker save "$COMMUNITY_OPERATOR_IMAGEREPO"/"$COMMUNITY_OPERATOR_BASE":"$COMMUNITY_OPERATOR_IMAGEVERSION" > ./temp/"$COMMUNITY_OPERATOR_BASE"-"$COMMUNITY_OPERATOR_IMAGEVERSION".tar
kind load image-archive ./temp/"$COMMUNITY_OPERATOR_BASE"-"$COMMUNITY_OPERATOR_IMAGEVERSION".tar

# Create the operator group
mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/community-operator-group.yaml | TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE "$SCRIPT_DIR"/mo > ./temp/rendered-local-community-operator-group.yaml
oc apply --filename ./temp/rendered-local-community-operator-group.yaml
cat ./temp/rendered-local-community-operator-group.yaml
rm ./temp/rendered-local-community-operator-group.yaml

# Create the Subscription
mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/community-operator-subscription.yaml |
	OPERATOR_BASE=$COMMUNITY_OPERATOR_BASE \
	OPERATOR_NAME=$COMMUNITY_OPERATOR_NAME \
	CATALOG_SOURCE=$CATALOG_SOURCE \
	CATALOG_NAMESPACE=$CATALOG_NAMESPACE \
	TNF_EXAMPLE_CNF_NAMESPACE=$TNF_EXAMPLE_CNF_NAMESPACE \
	"$SCRIPT_DIR"/mo > ./temp/rendered-local-community-operator-subscription.yaml
oc apply --filename ./temp/rendered-local-community-operator-subscription.yaml
cat ./temp/rendered-local-community-operator-subscription.yaml
rm ./temp/rendered-local-community-operator-subscription.yaml

# Gives time to the resource to come up and approves installation plan for the
# version.
sleep 30
oc patch installplan \
	--namespace "$TNF_EXAMPLE_CNF_NAMESPACE" \
	--type merge \
	--patch '{"spec":{"approved":true}}' \
	"$( \
		oc get installplan \
		--namespace "$TNF_EXAMPLE_CNF_NAMESPACE" |
			grep "$COMMUNITY_OPERATOR_NAME" |
			cut -f 1 -d \  \
	)" || { printf >&2 'Unable to approve the installation plan.\n'; exit 1;}
sleep 30
oc wait \
	--for=jsonpath=\{.status.phase\}=Succeeded \
	csv \
	--namespace "$TNF_EXAMPLE_CNF_NAMESPACE" \
	--selector=operators.coreos.com/hazelcast-platform-operator."${TNF_EXAMPLE_CNF_NAMESPACE}" \
	--timeout=600s || {
	printf >&2 'Timed out waiting for the operator to succeed.\n'
	oc get csv --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"
	exit 1
}
sleep 30
oc get csv --namespace "$TNF_EXAMPLE_CNF_NAMESPACE"

# Label the community operator
oc label clusterserviceversions.operators.coreos.com "$COMMUNITY_OPERATOR_NAME" -n "$TNF_EXAMPLE_CNF_NAMESPACE" test-network-function.com/operator=target
