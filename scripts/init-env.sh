set -x

# Initialization
REGISTRY_NAME=quay.io
#REGISTRY_NAME=cnfcert-local.redhat.com
REGISTRY=$REGISTRY_NAME/
DIRECTORY=testnetworkfunction/
OPERATOR_BUNDLE_BASE_IMAGE=nginx-operator
OPERATOR_IMAGE=$OPERATOR_BUNDLE_BASE_IMAGE:v0.0.1
OPERATOR_BUNDLE_IMAGE=$OPERATOR_BUNDLE_BASE_IMAGE-bundle:v0.0.1
OPERATOR_BUNDLE_IMAGE_FULL_NAME=$REGISTRY$DIRECTORY$OPERATOR_BUNDLE_IMAGE
OPERATOR_IMAGE_FULL_NAME=$REGISTRY$DIRECTORY$OPERATOR_IMAGE
OPERATOR_REGISTRY_POD_NAME_FULL=$(echo $OPERATOR_BUNDLE_IMAGE_FULL_NAME|sed 's/[\/|\.|:]/-/g')

# Truncate registry pod name if more than 63 characters
if [[ ${#OPERATOR_REGISTRY_POD_NAME_FULL} > 63 ]];then
    OPERATOR_REGISTRY_POD_NAME=${OPERATOR_REGISTRY_POD_NAME_FULL: -63}
else
    OPERATOR_REGISTRY_POD_NAME=$OPERATOR_REGISTRY_POD_NAME_FULL
fi
SECRET_NAME=foo-cert-sec
# Container executable
TNF_CONTAINER_CLIENT="docker"
CONTAINER_CLIENT="${CONTAINER_EXECUTABLE:-$TNF_CONTAINER_CLIENT}"

# Test Namespace
export TNF_EXAMPLE_CNF_NAMESPACE="${TNF_EXAMPLE_CNF_NAMESPACE:-tnf}"

# Create namespace if it does not exist
oc create namespace ${TNF_EXAMPLE_CNF_NAMESPACE} 2>/dev/null

# Default Namespace
export DEFAULT_NAMESPACE="${DEFAULT_NAMESPACE:-default}"

# Debug on-demand by default
export ON_DEMAND_DEBUG_PODS="${ON_DEMAND_DEBUG_PODS:-true}"

#Partner repo
export TNF_PARTNER_REPO="${TNF_PARTNER_REPO:-quay.io/testnetworkfunction}"
export TNF_DEPLOYMENT_TIMEOUT="${TNF_DEPLOYMENT_TIMEOUT:-240s}"

# Number of multus interfaces to create
MULTUS_IF_NUM="${MULTUS_IF_NUM:-2}"

TNF_NON_OCP_CLUSTER=false
MULTUS_ANNOTATION=""
NET_NAME="mynet"
# Check for non-ocp cluster 
res=`oc version | grep  Server`
if [ -z "$res" ]
then
   echo "non-ocp cluster detected"
   TNF_NON_OCP_CLUSTER=true
fi

# create Multus annotations
create_multus_annotation(){
  for (( NUM=0; NUM<$MULTUS_IF_NUM; NUM++ ))
  do
    MULTUS_ANNOTATION="${MULTUS_ANNOTATION}{ \"name\" : \"${NET_NAME}-$1-${NUM}\" },"
  done
}

# Only add annotation in non OCP clusters
if $TNF_NON_OCP_CLUSTER
then
  echo 'creating multus annotations'
  # IPv4
  create_multus_annotation "ipv4"
  # IPv6
  create_multus_annotation "ipv6"
fi

if [ $NUM -ge 0 ]; then
  export MULTUS_ANNOTATION="'[ ${MULTUS_ANNOTATION::-1} ]'"
fi

export 