#!/bin/bash

# A script to check if the necessary requirements for running the KinD partner cluster on Mac actually exist.

# Check if Docker is installed
CHECK_PODMAN=false
if ! [ -x "$(command -v docker)" ]; then

	# Check if podman is installed in a subsequent step
	if ! [ -x "$(command -v podman)" ]; then
		CHECK_PODMAN=true
    printf "Podman exists\n"
	fi

  # Default to recommend docker if podman is not installed
	if [ "$CHECK_PODMAN" == "false" ]; then
		printf "Docker is not installed. Please install Docker Desktop for Mac and try again.\n"
		exit 1
	fi
else 
  printf "Docker exists\n" 
fi

# Check if KIND_EXPERIMENTAL_PROVIDER is set in the environment
if [ "$CHECK_PODMAN" == "true" ]; then
	if [ -z "$KIND_EXPERIMENTAL_PROVIDER" ]; then
		printf "KIND_EXPERIMENTAL_PROVIDER is not set. Please set KIND_EXPERIMENTAL_PROVIDER to podman and try again.\n"
		exit 1
	fi
fi

cmd_exists() {
	local arg ret=0
	for arg; do
		if command -v "$arg" >/dev/null 2>&1; then
			printf '%s exists.\n' "$arg"
		else
			ret=1
			printf >&2 '%s does not exist, please, install.\n' "$arg"
		fi
	done
	return $ret
}

cmd_exists \
	jq \
	kind \
	kubectl \
	oc \
  sed \
  gsed \
  operator-sdk \
	python3 \
  go ||
	exit 1

