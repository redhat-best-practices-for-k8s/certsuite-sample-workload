#!/bin/bash

TIMEOUT=${WAIT_TIMEOUT:-600} # Default 10 minutes
START_TIME=$(date +%s)

# Get a list of all namespaces
namespaces=$(kubectl get ns --no-headers | awk '{ print $1 }')

# Wait for all pods in every namespace to be running
for namespace in $namespaces; do
	echo "Waiting for pods in namespace $namespace to be running..."
	while [ "$(kubectl get pods --field-selector=status.phase=Running -n "$namespace" 2>/dev/null | wc -l)" != "$(kubectl get pods -n "$namespace" 2>/dev/null | wc -l)" ]; do
		ELAPSED=$(($(date +%s) - START_TIME))
		if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
			echo "ERROR: Timed out after ${TIMEOUT}s waiting for all pods to be running"
			echo "Pods not in Running state:"
			kubectl get pods -A | grep -v Running | grep -v Completed || true
			exit 1
		fi
		sleep 1
	done
done

# All pods in all namespaces are now running
echo "All pods in all namespaces are running!"
