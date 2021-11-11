# CNF Certification Partner

This repository contains two main sections:
* test-partner:  A partner pod definition for use on a k8s CNF Certification cluster.
* local-test-infra:  A trivial example cluster, primarily intended to be used to run [test-network-function](https://github.com/test-network-function/test-network-function) test suites on a development machine.
This is the basic infrastructure required for "testing the tester".
Also includes a test operator.
# Glossary

* Pod Under Test (PUT): The Vendor Pod, usually provided by a CNF Partner.
* Operator Under Test (OT): The Vendor Operator, usually provided by a CNF Partner.
* Test Partner Pod (TPP): A Universal Base Image (UBI) Pod containing the test tools and dependencies to act as a traffic workload generator or receiver.  For generic cases, this currently includes ICMPv4 only.
* Debug Pod (DP): A Pod running [RHEL support tool image](https://catalog.redhat.com/software/containers/rhel8/support-tools/5ba3eaf9bed8bd6ee819b78b) deployed as part of a daemon set for accessing node information. DPs is deployed in "default" namespace
* CRD Under Test (CRD): A basic CustomResourceDefinition.


# Namespace

By default, TTP and DP are deployed in "default" namespace. all the other deployment files in this repository use ``tnf`` as default namespace. A specific namespace can be configured using:

```shell-script
export TNF_EXAMPLE_CNF_NAMESPACE="tnf" #tnf for example
```
# Test-partner

test-partner provides the basic configuration to create a CNF Test Partner Pod (TPP), which is used to verify proper operation of a Partner Vendor's Pod Under Test in a CNF Certification Cluster.  The Pod is composed of a single container, which is based off Universal Base Image (UBI) 8.  A minimal set of tools is installed on top of the base image to fulfill CNF Test dependency requirements:
* iputils (for ping)
* iproute (for ip)

If you are using a different test partner pod, please ensure you provide these or the image will be unable to run all CNF
Certification tests.

## Cloning the repository

The repository can be cloned to local machine using:

```shell-script
git clone git@github.com:test-network-function/cnf-certification-test-partner.git
```
## (Re)Building the container image

In order to build the test-partner image, the code should be [cloned locally](##cloning-the-repository). The following command should be issued:
```shell-script
docker build --no-cache -f Dockerfile -t testnetworkfunction/cnf-test-partner .
```

If needed (and authorized) the following will update the stored image:

```shell-script
docker push testnetworkfunction/cnf-test-partner
```

## Installing the partner pod

In order to create and deploy the partner pod, use the following:

```shell-script
make install-partner-pods
```

This will create a deployment named "partner" in the "default" namespace.  This Pod is the test partner for running CNF tests.
For disconnected environments, override the default image repo `quay.io/testnetworkfunction` by setting the environment variable named `TNF_PARTNER_REPO` to the local repo.
For environments with slow internet connection, override the default deployment timeout value (120s) by setting the environment variable named `TNF_DEPLOYMENT_TIMEOUT`.

*Note*: Nodes have to be properly labeled (`role=tnfpartner`) for the partner pod to be started.

# local-test-infra

Although any CNF Certification results should be generated using a proper CNF Certification cluster, there are times
in which using a local emulator can greatly help with test development.  As such, [local-test-infra](./local-test-infra)
provides a very simple PUT, OT, CRD, DP and TPP containing the minimal requirements to perform test cases.
These can be used in conjunction with a local kind or [minikube](https://minikube.sigs.k8s.io/docs/) cluster to perform local test development.


## Dependencies

In order to run the local test setup, the following dependencies are needed:
* [minikube](https://minikube.sigs.k8s.io/docs/)
* [VirtualBox](https://www.virtualbox.org/) (or another driver for minikube)
* [oc client](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#cli-linux)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup
Install the latest minikube by following the instructions at:
```https://minikube.sigs.k8s.io/docs/start/```

To start minikube, issue the following command:

```shell-script
minikube start --embed-certs --driver="virtualbox" --nodes 3 --network-plugin=cni --cni=calico 
```

The `--embed-certs` flag will cause minikube to embed certificates directly in its kubeconfig file.  
This will allow the minikube cluster to be reached directly from the container without the need of binding additional volumes for certificates.

The `--nodes 3` flag creates a cluster with one master node and two worker nodes. This is to support anti-affinity and pod-recreation test case.

The  `--network-plugin=cni --cni=calico` flags configure CNI support and installs Calico. This is required to install Multus later on.

To avoid having to specify this flag, set the `embed-certs` configuration key:

```shell-script
minikube config set embed-certs true
```
Or Alternatively, run:
```shell-script
make rebuild-minikube
```

## Start local-test-infra

To create the resources, issue the following command:

```shell-script
make install
```

This will create a PUT named "test" in `TNF_EXAMPLE_CNF_NAMESPACE` [namespace](#namespace), TPP named "tnfpartner" which can be used to run test suites, and Debug Daemonset named "debug". The
example `tnf_config.yml` in [`test-network-function`](https://github.com/test-network-function/test-network-function)
will use this local infrastructure by default.

Note that this command also creates OT and CRD resources.

To verify `test` pods are running: 

```shell-script
oc get pods -n $TNF_EXAMPLE_CNF_NAMESPACE -o wide
```

You should see something like this (note that the 2 test pods are running on different nodes due to a anti-affinity rule):
```shell-script
NAME                                                              READY   STATUS      RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
4c926df73b15df26b6874260a4f71ca3bf7c6ce2bdfd87aa90759a6aeb5rhpk   0/1     Completed   0          59s     10.244.0.5   minikube       <none>           <none>
nginx-operator-controller-manager-7f8f449fbd-fvn4f                2/2     Running     0          44s     10.244.0.6   minikube       <none>           <none>
quay-io-testnetworkfunction-nginx-operator-bundle-v0-0-1          1/1     Running     0          69s     10.244.2.6   minikube-m03   <none>           <none>
test-697ff58f87-88245                                             1/1     Running     0          2m20s   10.244.2.2   minikube-m03   <none>           <none>
test-697ff58f87-mfmpv                                             1/1     Running     0          2m20s   10.244.1.3   minikube-m02   <none>           <none>
```

To verify `partner` pod is running: 

```shell-script
oc get pods -n default -o wide
```

You should see something like this (note that the 2 test pods are running on different nodes due to a anti-affinity rule):
```shell-script
NAME                                                              NAME                          READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
tnfpartner-678db9858c-f9p4f   1/1     Running   0          142m   10.244.4.2   minikube-m05   <none>           <none>
```
## Stop local-test-infra

To tear down the local test cluster use the following command. It may take some time to completely stop the PUT, OT and PTT:

```shell-script
make clean
```
