#!/usr/bin/env bash
# TODO: needs refactoring to work with kind
# Initialization
# shellcheck disable=SC1001,SC2215
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

#setting sudo
sudo echo "setting sudo root"

# Initialization
TNF_CONTAINER_CLIENT="docker"
CONTAINER_CLIENT="${CONTAINER_EXECUTABLE:-$TNF_CONTAINER_CLIENT}"
CERT_EXE_UBUNTU=update-ca-certificates
CERT_EXE_REDHAT=update-ca-trust
echo "$(which $CERT_EXE_UBUNTU 2>/dev/null)"]
if [[ -n "$(which $CERT_EXE_UBUNTU 2>/dev/null)" ]];
then
  echo "Running on Ubuntu Linux"
  CERT_UPDATER=$CERT_EXE_UBUNTU
  CERT_PATH=/usr/local/share/ca-certificates/$REGISTRY_NAME.crt

elif [[ -n "$(which $CERT_EXE_REDHAT 2>/dev/null)" ]];
then
  echo "Running on Redhat/Fedora Linux"
  CERT_UPDATER=$CERT_EXE_REDHAT
  CERT_PATH=/etc/pki/ca-trust/source/anchors/$REGISTRY_NAME.crt
else
  echo "OS unknown, don't know how to update certificates"
  exit 1
fi
 
# Create certificates for registry authentication
rm -rf "$SCRIPT_DIR"/certs
mkdir "$SCRIPT_DIR"/certs
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes  -keyout "$SCRIPT_DIR"/certs/registry.key -out "$SCRIPT_DIR"/certs/registry.crt -subj "/CN=registry"  -addext "subjectAltName=DNS:${REGISTRY_NAME},IP:127.0.0.1"
openssl x509 -in "$SCRIPT_DIR"/certs/registry.crt -out "$SCRIPT_DIR"/certs/registry.pem -outform PEM
chmod 666 "$SCRIPT_DIR"/certs/*

# Enable the new certificates for use in the current host
sudo cp "$SCRIPT_DIR"/certs/registry.crt  "$CERT_PATH"
sudo $CERT_UPDATER


# Add the hostname to /etc/hosts
# shellcheck disable=SC2143 # Use grep -q.
if [ -z "$( grep "$REGISTRY_NAME" /etc/hosts)" ]
then
  REGISTRY_ADDRESS=$(hostname -I|awk '{print $1}')
  echo REGISTRY_ADDRESS= "$REGISTRY_ADDRESS" 
  sudo REGISTRY_ADDRESS1="$REGISTRY_ADDRESS" REGISTRY1="$REGISTRY_NAME" sh -c 'echo "$REGISTRY_ADDRESS1 $REGISTRY1" >> /etc/hosts'
else
  echo "entry already present"
fi
cat /etc/hosts


# Delete previous Registry
${CONTAINER_CLIENT} rm -f registry

# Copy the certificate to the minikube directory for use by minikube
mkdir -p "$HOME"/.minikube/certs
cp "$SCRIPT_DIR"/certs/registry.pem "$HOME"/.minikube/certs/. 

# Remove the docker registry 
${CONTAINER_CLIENT} rm -f registry

# Create the docker registry
${CONTAINER_CLIENT} run -d \Linux
  -v "$(pwd)"/"$SCRIPT_DIR"/certs:/certs:Z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -p 443:443 \
  registry:2

# Restart docker 
if [ "${CONTAINER_CLIENT}" = "docker" ];
then
  sudo systemctl restart docker
fi

echo "Created local registry at: ${REGISTRY_NAME}:443"
