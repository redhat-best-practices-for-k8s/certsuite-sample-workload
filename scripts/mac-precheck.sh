#!/bin/bash
# A script to check if the necessary requirements for running the KinD partner
# cluster on Mac actually exist.

# Checks whether all commands exits. Loops over the arguments, each one is a
# command name.
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

# Checks if docker is installed, then checks if podman is installed.
CHECK_PODMAN=false
if ! cmd_exists docker; then
	if cmd_exists podman; then
		CHECK_PODMAN=true
		printf 'Podman exists.\n'
	fi

	# Default to recommend docker if podman is not installed.
	if [ "$CHECK_PODMAN" = false ]; then
		printf 'Unable to continue, Docker is not installed.\n'
		exit 1
	fi
else
	printf 'Docker exists.\n'
fi

# Check if KIND_EXPERIMENTAL_PROVIDER is set in the environment.
if [ "$CHECK_PODMAN" = true ]; then
	if [ -z "$KIND_EXPERIMENTAL_PROVIDER" ]; then
		printf "KIND_EXPERIMENTAL_PROVIDER is not set. Please set KIND_EXPERIMENTAL_PROVIDER to podman and try again.\n"
		exit 1
	fi
fi
cmd_exists \
	go \
	gsed \
	jq \
	kind \
	kubectl \
	oc \
	operator-sdk \
	sed ||
	exit 1
