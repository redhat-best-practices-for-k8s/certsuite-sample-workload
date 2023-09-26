#!/bin/bash

# Get a list of all namespaces
namespaces=$(kubectl get ns --no-headers | awk '{ print $1 }')

# Wait for all pods in every namespace to be running
for namespace in $namespaces; do
	echo "Waiting for pods in namespace $namespace to be running..."
	while [ "$(kubectl get pods --field-selector=status.phase=Running -n "$namespace" | wc -l)" != "$(kubectl get pods -n "$namespace" | wc -l)" ]; do
		sleep 1
	done
done

# All pods in all namespaces are now running
echo "All pods in all namespaces are running!"
