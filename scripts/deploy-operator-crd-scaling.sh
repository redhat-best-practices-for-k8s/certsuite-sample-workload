#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/logging.sh

# Skip the install if MacOS
if [[ "$(uname -s)" == "Darwin"* ]]; then
  log_info "Skipping operator crd scaling install on MacOS"
  exit 0
fi

# Clone the repo.
CHECKOUT_FOLDER=crd-operator-scaling
rm -rf ${CHECKOUT_FOLDER}

log_info "Cloning crd operator version ${CHECKOUT_FOLDER}."
git clone "$CRD_SCALING_URL" -b "$CRD_SCALING_TAG" "${CHECKOUT_FOLDER}" || exit 1

## Operator installation.
## Change to checkout folder first.
pushd "${CHECKOUT_FOLDER}" || exit 1

## Deploy operator using container matching the checkout version ($CRD_SCALING_TAG).
log_info "Deploying operator with container image version ${CRD_SCALING_TAG}"

make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:"${CRD_SCALING_TAG}"
oc wait deployment new-pro-controller-manager -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout=240s

# Deploy custom cluster role needed by the deployment that the controller will create.
make addrole

# Deploy CR samples to trigger the controller.
oc apply -f config/samples --validate=false

TIMEOUT_MINS="10"
# Wait for deployment "jack" to be created.
END_TIME=$(date -ud "${TIMEOUT_MINS} minute" +%s)

log_info "Waiting for deployment jack to appear until $(date --date=@"${END_TIME}")"

DEPLOYMENT_FOUND=false
while [[ $(date -u +%s) -le $END_TIME ]]; do
  if kubectl get deployment jack -n "$TNF_EXAMPLE_CNF_NAMESPACE" ; then
    DEPLOYMENT_FOUND=true
    break
  fi

  log_info "Deployment jack not found yet. Waiting 5 secs..."
  sleep 5
done

if ! ${DEPLOYMENT_FOUND} ; then
	log_error "Timeout waiting for operator's deployment."
	exit 1
fi

# Wait until jack deployment's pods are ready.
log_info "Waiting ${TIMEOUT_MINS}m for operator's deployment jack in namespace ${TNF_EXAMPLE_CNF_NAMESPACE} to be ready."
if ! oc wait deployment jack \
	    --for=condition=available \
	    --namespace "$TNF_EXAMPLE_CNF_NAMESPACE" \
	    --timeout="${TIMEOUT_MINS}"m ; then
  log_error "Operator's deployment jack is not ready."
  exit 1
fi

oc get deployment jack -n "$TNF_EXAMPLE_CNF_NAMESPACE"

# Return from the checkout folder.
popd || exit 1

# Delete the checkout folder after installation.
log_info "Removing crd operator checkout folder ${CHECKOUT_FOLDER}"
rm -rf "${CHECKOUT_FOLDER}"
