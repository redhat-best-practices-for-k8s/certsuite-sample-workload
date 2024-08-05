#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
mkdir -p ./temp
"$SCRIPT_DIR"/mo ./test-target/cpu-exclusive-pool-rt-sched-policy-pod.yaml >./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml
"$SCRIPT_DIR"/mo ./test-target/cpu-shared-pool-non-rt-sched-policy-pod.yaml >./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
oc apply --filename ./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml
oc apply --filename ./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
rm ./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml
rm ./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
oc wait deployment test -n "$CERTSUITE_EXAMPLE_NAMESPACE" --for=condition=available --timeout="$CERTSUITE_DEPLOYMENT_TIMEOUT"
