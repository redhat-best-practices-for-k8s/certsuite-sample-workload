# CNF Certification Partner

This repository contains two main sections:
* test-partner:  A partner pod definition for use on a K8S CNF Certification cluster.
* local-test-infra:  A trivial example cluster, primarily intended to be used to run
[test-network-function](https://github.com/test-network-function/test-network-function) test suites on a development machine.
This is the basic infrastructure required for "testing the tester".

# Glossary

* Pod Under Test (PUT): The Vendor Pod, usually provided by a CNF Partner.
* Test Partner Pod (TPP): A Universal Base Image (UBI) Pod containing the test tools and dependencies to act as a
traffic workload generator or receiver.  For generic cases, this currently includes ICMPv4 only.

# test-partner

test-partner provides the basic configuration to create a CNF Test Partner Pod (TPP), which is used to verify proper
operation of a Partner Vendor's Pod Under Test in a CNF Certification Cluster.  The Pod is composed of a single
container, which is based off Universal Base Image (UBI) 7.  A minimal set of tools is installed on top of the base
image to fulfill CNF Test dependency requirements:
* iputils (for ping)
* iproute (for ip)

If you are using a different test partner pod, please ensure you provide these or the image will be unable to run all CNF
Certification tests.

## (Re)Building the container image

In order to build the test-partner image, use the following:

```shell-script
docker build --no-cache -f Dockerfile -t testnetworkfunction/cnf-test-partner .
```

If needed (and authorised) the following will update the stored image:

```shell-script
docker push testnetworkfunction/cnf-test-partner
```

## Installing the partner pod

First, clone this repository:

```shell-script
git clone git@github.com:test-network-function/cnf-certification-test-partner.git
```

Next, create the OpenShift resources:

```shell-script
cd cnf-certification-test-partner/test-partner
oc create -f ./namespace.yaml
oc create -f ./partner.yaml
```

This will create a Pod named "partner" in the `tnf` namespace.  This Pod is the test partner for running Generic CNF
tests.

*Note*: Nodes have to be properly labeled (`role=partner`) for the partner pod to be started.

To add the label to a selected node, issue the following command: 
```shell-script:
oc label nodes <node-name> role=partner
```

## TODO

* Create an OpenShift Operator for partner.yaml.  This has very little merit for our use-case, but does align with the
  best practices Red Hat recommends.
* Consider a transition to UBI 8.

# local-test-infra

Although any CNF Certification results should be generated using a proper CNF Certification cluster, there are times
in which using a local emulator can greatly help with test development.  As such, [local-test-infra](./local-test-infra)
provides a very simple PUT and TPP containing the minimial requirements to peform `generic` test cases.
These can be used in conjunction with a local kind or [minikube](https://minikube.sigs.k8s.io/docs/) cluster to perform local test development.


## Dependencies

In order to run the local test setup, the following dependencies are needed:
* [minikube](https://minikube.sigs.k8s.io/docs/)
* [VirtualBox](https://www.virtualbox.org/) (or another driver for minikube)
* [oc client](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#cli-linux)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup

To start minikube, issue the following command:

```shell-script
minikube start --embed-certs --driver="virtualbox"
```

The `--embed-certs` flag will cause minikube to embed certificates directly in its kubeconfig file.  
This will allow the minikube cluster to be reached directly from the container without the need of binding additional volumes for certificates.

To avoid having to specify this flag, set the `embed-certs` configuration key:

```shell-script
minikube config set embed-certs true
```

## Start local-test-infra
To create the PUT and TPP in the `tnf` namespace, issue the following command:

```shell-script
make install
```

This will create a PUT named "test", and a TPP named "partner" which can be used to run `generic` test suite. The
example `test-configuration.yaml` in [`test-network-function`](https://github.com/test-network-function/test-network-function)
will use this local infrastructure by default.

To verify `partner` and `test` pods are running: 

```shell-script
oc get pods -n tnf -o wide
```

You should see something like this:
```shell-script
NAME      READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
partner   1/1     Running   0          22m   172.17.0.3   minikube   <none>           <none>
test      1/1     Running   0          22m   172.17.0.4   minikube   <none>           <none>
```

To avoid having to specify the `tnf` namespace with the `-n` option, set the namespace for the current context:

```shell-script
oc config set-context $(oc config current-context) --namespace=tnf
```

## Stop local-test-infra

To tear down the local test cluster use the following command. It may take some time to completely stop both pods:

```shell-script
make clean
```

