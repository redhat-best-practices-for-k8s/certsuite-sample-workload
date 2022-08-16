#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh

# ipv6 service
mkdir -p ./temp
cat ./test-target/service.yaml | SERVICE_NAME="test-service-dualstack" APP="testdp" IP_FAMILY_POLICY="PreferDualStack" IP_FAMILIES='["IPv4","IPv6"]' "$SCRIPT_DIR"/mo > ./temp/rendered-local-service-under-test-template.yaml
oc apply --filename ./temp/rendered-local-service-under-test-template.yaml
rm ./temp/rendered-local-service-under-test-template.yaml

# dual stack service
cat ./test-target/service.yaml | SERVICE_NAME="test-service-ipv6" APP="testdp" IP_FAMILY_POLICY="SingleStack" IP_FAMILIES='["IPv6"]' "$SCRIPT_DIR"/mo > ./temp/rendered-local-service-under-test-template.yaml
oc apply --filename ./temp/rendered-local-service-under-test-template.yaml
rm ./temp/rendered-local-service-under-test-template.yaml