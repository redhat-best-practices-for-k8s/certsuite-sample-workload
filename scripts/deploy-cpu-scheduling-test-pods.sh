#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh
mkdir -p ./temp

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/cpu-exclusive-pool-rt-sched-policy-pod.yaml | "$SCRIPT_DIR"/mo >./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml

# shellcheck disable=SC2002 # Useless cat.
cat ./test-target/cpu-shared-pool-non-rt-sched-policy-pod.yaml | "$SCRIPT_DIR"/mo >./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
oc apply --filename ./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml
oc apply --filename ./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
rm ./temp/rendered-cpu-exclusive-pool-rt-sched-policy-pod.yaml
rm ./temp/rendered-cpu-shared-pool-non-rt-sched-policy-pod.yaml
oc wait deployment test -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout="$TNF_DEPLOYMENT_TIMEOUT"
