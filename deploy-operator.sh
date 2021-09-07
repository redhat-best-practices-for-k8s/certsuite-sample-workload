set -x

# Create secret (must be named cert.pem)
cp ../certs/registry.pem ../certs/cert.pem
oc create secret generic foo-cert-sec --from-file=../certs/cert.pem

# Remove the docker registry 
docker rm -f registry

# Create the docker registry
docker run -d \
  --restart=always \
  --name registry \
  -v $(pwd)/../certs:/certs:Z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  -p 443:443 \
  registry:2

# Install operator sdk
## Configure platform
export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
export OS=$(uname | awk '{print tolower($0)}')

## Download executable
export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.11.0
curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}

## Download the auth key
gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E

curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt
curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc
gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc

OUT=$(grep operator-sdk_${OS}_${ARCH} checksums.txt | sha256sum -c -)
echo $OUT
if [ "$OUT"="operator-sdk_linux_amd64: OK" ];
then
  chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
  echo "operator-sdk configured"
else 
  echo "Error: Checksum mismatch, quitting"
  exit 1
fi

# create the test operator
mkdir nginx-operator
cd nginx-operator
operator-sdk init --domain cnftest-local.redhat.com --plugins helm
 
# Create a simple nginx API using Helm’s built-in chart boilerplate (from helm create):
operator-sdk create api --group cnftest --version v0 --kind Nginx

# Logging registry before using
docker logs registry 

# Build and push the operator image:
make docker-build docker-push IMG="cnftest-local.redhat.com/nginx-operator:v0.0.1"

# Install OLM
operator-sdk olm install

# Configure the operator manifest
mkdir -p config/manifests/bases

# Create configration
cat > config/manifests/bases/nginx-operator.clusterserviceversion.yaml <<-'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: ClusterServiceVersion
metadata:
  annotations:
    alm-examples: '[]'
    capabilities: Basic Install
  name: nginx-operator.v0.0.0
  namespace: placeholder
spec:
  apiservicedefinitions: {}
  customresourcedefinitions: {}
  description: cnftest
  displayName: test-operator
  icon:
  - base64data: ""
    mediatype: ""
  install:
    spec:
      deployments: null
    strategy: ""
  installModes:
  - supported: false
    type: OwnNamespace
  - supported: false
    type: SingleNamespace
  - supported: false
    type: MultiNamespace
  - supported: true
    type: AllNamespaces
  keywords:
  - cnftest
  links:
  - name: Nginx Operator
    url: https://nginx-operator.domain
  maintainers:
  - email: deliedit@redhat.com
    name: david
  maturity: alpha
  provider:
    name: redhat
  version: 0.0.0
EOF

# Make and push the operator bundle
make bundle IMG="cnftest-local.redhat.com/nginx-operator:v0.0.1"
make bundle-build bundle-push

# Deploy the operator bundle
operator-sdk run bundle cnftest-local.redhat.com/nginx-operator-bundle:v0.0.1 --ca-secret-name foo-cert-sec

# Label and annotate the operator
## First call with csv fails, subsequent calls are ok
oc label csv nginx-operator.v0.0.1 test-network-function.com/operator=target
oc label csv nginx-operator.v0.0.1 test-network-function.com/operator=target
oc annotate csv nginx-operator.v0.0.1 test-network-function.com/subscription_name='["nginx-operator-v0-0-1-sub"]'