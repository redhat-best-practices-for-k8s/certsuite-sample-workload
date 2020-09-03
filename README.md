# cnf-certification-test-partner

This repository contains two major sections:
* test-partner:  Used on a K8S CNF Certification cluster to verify proper operation of a Vendor's Pod Under Test
* local-test-infra:  Used to test [test-network-function](https://github.com/redhat-nfvpe/test-network-function) and
related test suites on a local development machine.  This is infrastructure required for "testing the tester".

## Glossary

* Pod Under Test (PUT): The Vendor Pod, usually provided by a CNF Partner.
* Test Partner Pod (TPP): A Universal Base Image (UBI) Pod containing the test tools and dependencies to act as a
traffic workload generator or receiver.  For generic cases, this currently includes ICMPv4 only.

## test-partner

This repository provides the infrastructure to create a CNF test partner Pod, which is used to verify proper operation
of a Partner Vendor's Pod Under Test in a CNF Certification Cluster.  The Pod is composed of a single container, which
is based off Universal Base Image (UBI) 7.  A minimal set of tools is installed on top of the base image to fulfill CNF
Test dependency requirements:

* iputils (for ping)
* iproute (for ip)

### TODO

* Move to a more centralized container repository instead of relying on rgoulding's development repository.
* Create an OpenShift Operator for partner.yaml.  This has very little merit for our use-case, but does align with the
  best practices Red Hat recommends.
* Consider a transition to UBI 8.

### Building the container image

In order to build the container image, issue the following command:

```shell script
docker build --no-cache -f Dockerfile -t rgoulding/cnf-test-partner .
```

In order to push the container image, issue the following command:

```shell script
docker push rgoulding/cnf-test-partner
```

### Installing the partner pod

First, clone this repository:

```shell script
git clone git@github.com:redhat-nfvpe/cnf-certification-test-partner.git
```

Next, create the OpenShift resources:

```shell script
cd cnf-certification-test-partner/test-partner
oc create -f ./partner.yaml
```

This will create a Pod named "partner" in the default namespace.  This Pod is the test partner for running Generic CNF
tests.

## local-test-infra

Although any CNF Certification results should be generated using a proper CNF Certification cluster, there are times
in which using a local emulator can greatly help with test development.  As such, [local-test-infra](./local-test-infra)
is abstracted to provide a low spec'd PUT and TPP containing the minimial requirements to peform generic test cases.
These can be used in conjunction with a local kind or minikube cluster to perform local test development.

### local-test-infra Installation using minikube

To start minikube, issue the following command:

```shell script
minikube start --driver="virtualbox"
```

To create the PUT and TPP, issue the following command:

```shell script
make install
```

This will create a PUT named "test", and a TPP named "partner" which can be used to run generic test suite cases.  Just
specify [local-test-infra/conf.yaml](./local-test-infra/conf.yaml) to utilize the local environment in conjunction with
[test-network-function](https://github.com/redhat-nfvpe/test-network-function).

### local-test-infra Un-installation

A utility make target is provided to tear down the local test cluster:

```shell script
make clean
```
