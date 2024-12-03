#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2086,SC1083,SC2188,SC2027

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

<<COMMENT1
#check if operator-sdk is installed and install it if needed
if [[ -z "$(which operator-sdk 2>/dev/null)" ]]; then
	echo "operator-sdk executable cannot be found in the path. Will try to install it."
	"$SCRIPT_DIR"/install-operator-sdk.sh
else
	echo "operator-sdk was found in the path, no need to install it"
fi
COMMENT1

# Installing OLM
"$SCRIPT_DIR"/install-olm.sh
"$SCRIPT_DIR"/delete-operator.sh

<<COMMENT2
	# Creates a secret if a pem file exists
	"$SCRIPT_DIR"/create-secret.sh

	ADD_SECRET=""

	# shellcheck disable=SC2143 # Use grep -q.
	if [[ -n "$(oc get secret -n "$CERTSUITE_EXAMPLE_NAMESPACE" | awk '{print $1}' | grep "$SECRET_NAME")" ]]; then
		ADD_SECRET="--ca-secret-name $SECRET_NAME"
	fi

	# Deploy the operator bundle
	operator-sdk run bundle "$OPERATOR_BUNDLE_IMAGE_FULL_NAME" -n "$CERTSUITE_EXAMPLE_NAMESPACE" "$ADD_SECRET"

	# Important: this line (output of command is now captured) is required to enable csv short names with non-ocp cluster
	# If short name "csv" is used, the call will fail the first time
	# With long name the first time it will work and subsequent time it will work with long or short names
	CSV_MATCH=$(oc get clusterserviceversions.operators.coreos.com -n "$CERTSUITE_EXAMPLE_NAMESPACE" -ogo-template='{{ range .items}}{{.metadata.name}}{{end}}' 2>/dev/null | grep "nginx-operator.v0.0.1")
	if [ "$CSV_MATCH" = "nginx-operator.v0.0.1" ]; then
		echo "CSV successfully deployed"
	else
		echo "ERROR: CSV not deployed. Operator deployment failed -- interrupting tests"
		exit 1
	fi
COMMENT2

# Deploy single namespace operator nginx in namespace nginx-ops
oc apply --filename ./test-target/operator-single-install-mode.yaml

# Wait until operator pods is in running state
OPERATOR_NS="nginx-ops"
MAX_COUNT=10
CURRENT_COUNT=0

while [[ "$CURRENT_COUNT" -lt "$MAX_COUNT" ]]; do
	((CURRENT_COUNT++))

	POD_COUNT=$(oc get pods -n "$OPERATOR_NS" --no-headers 2>/dev/null | wc -l)

	if [[ $POD_COUNT -eq 0 ]]; then
		echo "No pods found in "$OPERATOR_NS" namespace. Waiting for pods to be created..."
		sleep 5
	else
		echo "Pods found in "$OPERATOR_NS" namespace."
		break
	fi
done

if [[ "$CURRENT_COUNT" -ge "$MAX_COUNT" ]]; then
	echo "Maximum check count ($MAX_COUNT) reached. Exiting without finding pods in "$OPERATOR_NS"."
else
	echo "Exited after "$CURRENT_COUNT" check(s). Pods are ready."
fi
