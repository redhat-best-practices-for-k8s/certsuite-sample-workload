#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

usage(){
    echo "$0 deploy or
$0 delete"
     exit 1
}

ACTION=""
if [ -z "$1" ]; then
    echo "Missing parameters, run :"
    usage
fi
if [[ "$1" == "deploy" ]]; then
    ACTION="apply"
elif [[ "$1" == "delete" ]]; then
    ACTION="delete"
else
    echo "Bad parameter, run :"
    usage
fi

# ipv6 service
mkdir -p ./temp
# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/service.yaml | SERVICE_NAME="test-service-dualstack" APP="testdp" IP_FAMILY_POLICY="PreferDualStack" IP_FAMILIES='["IPv4","IPv6"]' "$SCRIPT_DIR"/mo > ./temp/rendered-local-service-under-test-template.yaml
oc $ACTION --filename ./temp/rendered-local-service-under-test-template.yaml
rm ./temp/rendered-local-service-under-test-template.yaml

# dual stack service
# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/service.yaml | SERVICE_NAME="test-service-ipv6" APP="testdp" IP_FAMILY_POLICY="SingleStack" IP_FAMILIES='["IPv6"]' "$SCRIPT_DIR"/mo > ./temp/rendered-local-service-under-test-template.yaml
oc $ACTION --filename ./temp/rendered-local-service-under-test-template.yaml
rm ./temp/rendered-local-service-under-test-template.yaml
