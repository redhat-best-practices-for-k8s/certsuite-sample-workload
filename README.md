# cnf-certification-test-partner

This repository provides the infrastructure to create a CNF test partner Pod.  The Pod is composed of a single
container, which is based off Universal Base Image (UBI) 7.  A minimal set of tools is installed on top of the base
image to fulfill CNF Test dependency requirements:

* iputils (for ping)
* iproute (for ip)

## TODO

* Move to a more centralized container repository instead of relying on rgoulding's development repository.
* Create an OpenShift Operator for partner.yaml.  This has very little merit for our use-case, but does align with the
  best practices Red Hat recommends.
* Consider a transition to UBI 8.

## Building the container image

In order to build the container image, issue the following command:

```shell script
docker build --no-cache -f Dockerfile -t rgoulding/cnf-test-partner .
```

In order to push the container image, issue the following command:

```shell script
docker push rgoulding/cnf-test-partner
```

## Installing the partner pod

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
