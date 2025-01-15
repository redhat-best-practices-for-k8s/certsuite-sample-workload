#!/usr/bin/env bash
set -x

#setting sudo
sudo echo "setting sudo root"
if [[ -n "$(which sw_vers 2>/dev/null)" ]]; then
	echo "Installing operator-sdk for Mac"
	brew install operator-sdk
else
	echo "Installing operator-sdk for Linux"

	# Install operator sdk
	## Configure platform
	ARCH="$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n "$(uname -m)" ;; esac)"
	OS="$(uname | awk '{print tolower($0)}')"
	export ARCH OS

	## Download executable
	export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.39.1
	curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_"${OS}"_"${ARCH}"

	## Download the auth key
	gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E

	curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt
	curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc
	gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc

	OUT=$(grep operator-sdk_"${OS}"_"${ARCH}" checksums.txt | sha256sum -c -)
	echo "$OUT"
	if [ "$OUT" = "operator-sdk_linux_amd64: OK" ]; then
		chmod +x operator-sdk_"${OS}"_"${ARCH}" && sudo mv operator-sdk_"${OS}"_"${ARCH}" /usr/local/bin/operator-sdk
		echo "operator-sdk configured"
	else
		echo "Error: Checksum mismatch, quitting"
		exit 1
	fi
fi
