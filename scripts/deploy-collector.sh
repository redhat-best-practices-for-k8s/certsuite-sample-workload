#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/logging.sh

CHECKOUT_FOLDER=collector-deployment
rm -rf ${CHECKOUT_FOLDER}

log_info "Cloning collector"
# git clone "$COLLECTOR_URL" -b "$COLLECTOR_TAG" "${CHECKOUT_FOLDER}" || exit 1  # TODO: uncomment this line when COLLECTOR_TAG is ready
git clone "$COLLECTOR_URL" "${CHECKOUT_FOLDER}" || exit 1

pushd "${CHECKOUT_FOLDER}" || exit 1

log_info "Deploying MySQL"
make deploy-mysql

log_info "Deploying collector"
make deploy-collector

popd || exit 1

# Delete the checkout folder after installation.
log_info "Removing collector checkout folder ${CHECKOUT_FOLDER}"
rm -rf "${CHECKOUT_FOLDER}"
