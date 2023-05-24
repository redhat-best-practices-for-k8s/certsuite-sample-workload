#!/bin/bash

# A script to check if the necessary requirements for running the KinD partner cluster on Mac actually exist.

# Check if Docker is installed
CHECK_PODMAN=false
if ! [ -x "$(command -v docker)" ]; then

	# Check if podman is installed in a subsequent step
	if ! [ -x "$(command -v podman)" ]; then
		CHECK_PODMAN=true
	fi

  # Default to recommend docker if podman is not installed
	if [ "$CHECK_PODMAN" == "false" ]; then
		echo "Docker is not installed. Please install Docker Desktop for Mac and try again."
		exit 1
	fi
else 
  echo "Docker is installed. $(docker --version)" 
fi

# Check if podman is installed and KIND_EXPERIMENTAL_PROVIDER is set in the environment
if [ "$CHECK_PODMAN" == "true" ]; then
	if ! [ -x "$(command -v podman)" ]; then
		echo "Neither docker or podman is not installed. Please install docker and try again."
		exit 1
	else 
		echo "podman is installed. $(podman --version)" 
	fi

	if [ -z "$KIND_EXPERIMENTAL_PROVIDER" ]; then
		echo "KIND_EXPERIMENTAL_PROVIDER is not set. Please set KIND_EXPERIMENTAL_PROVIDER to podman and try again."
		exit 1
	fi
fi

# Check if oc is installed
if ! [ -x "$(command -v oc)" ]; then
  echo "oc is not installed. Please install oc and try again."
  exit 1
else 
  echo "oc is installed."
  oc version 
fi

# Check if kubectl is installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo "kubectl is not installed. Please install kubectl and try again."
  exit 1
else 
  echo "kubectl is installed."
  kubectl version
fi

# Check if kind is installed
if ! [ -x "$(command -v kind)" ]; then
  echo "kind is not installed. Please install kind and try again."
  exit 1
else 
  echo "kind is installed."
  kind version
fi

# Check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
  echo "jq is not installed. Please install jq and try again."
  exit 1
else 
  echo "jq is installed."
  jq --version
fi

# Check if sed is installed
if ! [ -x "$(command -v sed)" ]; then
  echo "sed is not installed. Please install sed and try again."
  exit 1
else 
  echo "sed is installed."
  sed --version | grep GNU
fi

# Check if gsed is installed
if ! [ -x "$(command -v gsed)" ]; then
  echo "gsed is not installed. Please install gsed and try again."
  exit 1
else 
  echo "gsed is installed."
  gsed --version | grep GNU
fi

# Check if operator-sdk is installed
if ! [ -x "$(command -v operator-sdk)" ]; then
  echo "operator-sdk is not installed. Please install operator-sdk and try again."
  exit 1
else 
  echo "operator-sdk is installed."
  operator-sdk version
fi

# Check if go is installed
if ! [ -x "$(command -v go)" ]; then
  echo "go is not installed. Please install go and try again."
  exit 1
else 
  echo "go is installed."
  go version
fi
