#!/usr/bin/env bash
set -x
# Create certificates for registry authentication
rm -rf ../certs
mkdir ../certs
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes  -keyout ../certs/registry.key -out ../certs/registry.crt -subj "/CN=registry"  -addext "subjectAltName=DNS:cnftest-local.redhat.com,IP:127.0.0.1"
openssl x509 -in ../certs/registry.crt -out ../certs/registry.pem -outform PEM
chmod 666 ../certs/*

# Add the hostname to /etc/hosts
if [ -z $( grep "cnftest-local.redhat.com" /etc/hosts) ]
then
  DOCKER_IP=$( ip a show dev eth0 | grep  "inet "|awk -F" "  '{print $2}'|awk -F"/"  '{print $1}' )
  echo DOCKER_IP= $DOCKER_IP 
  sudo DOCKER_IP1="$DOCKER_IP" sh -c 'echo "$DOCKER_IP1 cnftest-local.redhat.com" >> /etc/hosts'
else 
  echo "entry already present"
fi
cat /etc/hosts

# Enable the new certificates for use in the current host
sudo mkdir -p  /usr/local/share/ca-certificates/cnfcert
sudo cp ../certs/registry.crt  /usr/local/share/ca-certificates/cnfcert/.
sudo update-ca-certificates

# Copy the certificate to the minikube directory for use by minikube
mkdir -p $HOME/.minikube/certs
cp ../certs/registry.pem $HOME/.minikube/certs/.  