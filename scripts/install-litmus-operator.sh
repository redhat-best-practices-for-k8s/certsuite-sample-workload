#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
# apply the crds and wait for them
oc apply -f ./scripts/operator-ce.yaml
oc wait crd chaosengines.litmuschaos.io --timeout=320s --for=condition=established
oc wait crd chaosresults.litmuschaos.io --timeout=320s --for=condition=established
oc wait crd chaosexperiments.litmuschaos.io --timeout=320s --for=condition=established
oc wait deployment chaos-operator-ce -n litmus --for=condition=available --timeout=320s
