<!-- markdownlint-disable line-length no-bare-urls -->
# CNF Certification Partner

[![tests](https://github.com/test-network-function/cnf-certification-test-partner/actions/workflows/pre-main.yml/badge.svg)](https://github.com/test-network-function/cnf-certification-test-partner/actions/workflows/pre-main.yml)
[![release)](https://img.shields.io/github/v/release/test-network-function/cnf-certification-test-partner?color=blue&label=%20&logo=semver&logoColor=white&style=flat)](https://github.com/test-network-function/cnf-certification-test-partner/releases)
[![red hat](https://img.shields.io/badge/red%20hat---?color=gray&logo=redhat&logoColor=red&style=flat)](https://www.redhat.com)
[![openshift](https://img.shields.io/badge/openshift---?color=gray&logo=redhatopenshift&logoColor=red&style=flat)](https://www.redhat.com/en/technologies/cloud-computing/openshift)
[![license](https://img.shields.io/github/license/test-network-function/cnf-certification-test-partner?color=blue&labelColor=gray&logo=apache&logoColor=lightgray&style=flat)](https://github.com/test-network-function/cnf-certification-test-partner/blob/master/LICENSE)

This repository contains two main sections:

* test-partner:  Partner debug pods definition for use on a k8s CNF Certification cluster. Used to run platform and networking tests.
* test-target:  A trivial example CNF (including a replicaset/deployment, a CRD and an operator), primarily intended to be used to run [test-network-function](https://github.com/test-network-function/test-network-function) test suites on a development machine.

Together, they make up the basic infrastructure required for "testing the tester". The partner debug pod is always required for platform tests and networking tests.

# Glossary

* Pod Under Test (PUT): The Vendor Pod, usually provided by a CNF Partner.
* Operator Under Test (OT): The Vendor Operator, usually provided by a CNF Partner.
* Debug Pod (DP): A Pod running [a UBI8-based support image](https://quay.io/repository/testnetworkfunction/debug-partner) deployed as part of a daemon set for accessing node information. DPs is deployed in "default" namespace
* CRD Under Test (CRD): A basic CustomResourceDefinition.

# Prerequisites

## Namespace

By default, DP are deployed in "default" namespace. all the other deployment files in this repository use ``tnf`` as default namespace. A specific namespace can be configured using:

```shell-script
export TNF_EXAMPLE_CNF_NAMESPACE="tnf" #tnf for example
```

## On-demand vs always on debug pods

By default debug pods are installed on demand when the tnf test suite is deployed. To deploy debug pods on all nodes in the cluster, configure the following environment variable:

```shell-script
export ON_DEMAND_DEBUG_PODS=false
```

## Cloning the repository

The repository can be cloned to local machine using:

```shell-script
git clone git@github.com:test-network-function/cnf-certification-test-partner.git
```

# Installing the partner pod

In order to create and deploy the partner debug pods (daemonset), use the following:

```shell-script
make install-partner-pods
```

This will create a deployment named "partner" in the "default" namespace. This Pod is the test partner for running CNF tests.
For disconnected environments, override the default image repo `quay.io/testnetworkfunction` by setting the environment variable named `TNF_PARTNER_REPO` to the local repo.
For environments with slow internet connection, override the default deployment timeout value (120s) by setting the environment variable named `TNF_DEPLOYMENT_TIMEOUT`.

# Installing the Test-target

Although any CNF Certification results should be generated using a proper CNF Certification cluster, there are times
in which using a local emulator can greatly help with test development. As such, [test-target](./test-target)
provides a simple PUT, OT, CRD, which satisfies the minimal requirements to perform test cases.
These can be used in conjunction with a local [kind](https://kind.sigs.k8s.io/) cluster to perform local test development.

## Dependencies

In order to run the local test setup, the following dependencies are needed:

* [vagrant](https://www.vagrantup.com/downloads)
* [kind](https://kind.sigs.k8s.io/)
* [Docker](https://docs.docker.com/get-docker/)
* [oc client](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#cli-linux)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup with docker and kind

Install the latest docker version ( https://docs.docker.com/engine/install/fedora ):

```shell-script
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

sudo dnf -y install dnf-plugins-core

sudo dnf install docker-ce docker-ce-cli containerd.io
```

Perform the post install ( https://docs.docker.com/engine/install/linux-postinstall ):

```shell-script
 sudo systemctl start docker.service
 sudo systemctl enable docker.service
 sudo systemctl enable containerd.service
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker 
```

Configure IPv6 in docker ( https://docs.docker.com/config/daemon/ipv6/ ):

```shell-script
# update docker config
sudo bash -c 'cat <<- EOF > /etc/docker/daemon.json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF'
```

Enable IPv6 with:

```shell-script
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0
```

to persist IPv6 support, edit or add the following lines in the /etc/sysctl.conf file

```shell-script
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
```

disable firewall, if present, as multus interfaces will not be able to communicate.

Note: if docker is already running after running the command below, also restart docker as taking the firewall down will remove the docker rules:

```shell-script
sudo systemctl stop firewalld
```

restart docker:

```shell-script
sudo systemctl restart docker
```

Download and install Kubernetes In Docker (Kind):

```shell-script
curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-linux-amd64
```

Configure a cluster with 4 worker nodes and one master node ( dual stack ):

```shell-script
cat <<- EOF > config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: dual
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
kind create cluster --config=config.yaml
```

Increase max files limit to prevent issue due to the large cluster size ( see https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files ):

```shell-script
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

To make the changes persistent, edit the file /etc/sysctl.conf and add these lines:

```shell-script
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
```

### Deploy both test target and test partner as a local-test-infra

To create the resources, issue the following command:

```shell-script
make install
```

This will create a PUT named "test" in `TNF_EXAMPLE_CNF_NAMESPACE` [namespace](#namespace) and Debug Daemonset named "debug". The
example `tnf_config.yml` in [`test-network-function`](https://github.com/test-network-function/test-network-function)
will use this local infrastructure by default.

Note that this command also creates OT and CRD resources.

To verify `test` pods are running:

```shell-script
oc get pods -n $TNF_EXAMPLE_CNF_NAMESPACE -o wide
```

You should see something like this (note that the 2 test pods are running on different nodes due to a anti-affinity rule):

```shell-script
$ oc get pods -ntnf -owide
NAME                                                    READY   STATUS    RESTARTS   AGE
hazelcast-platform-controller-manager-6bbc968f9-fmmbs   1/1     Running   0          3m19s
test-0                                                  1/1     Running   0          84m
test-1                                                  1/1     Running   0          83m
test-66f77bd94-2w4l8                                    1/1     Running   0          85m
test-66f77bd94-6kd6j                                    1/1     Running   0          85m

```

### Delete local-test-infra

To tear down the local test infrastructure from the cluster, use the following command. It may take some time to completely stop the PUT, CRD, OT, and DP:

```shell-script
make clean
```

## Setup with Vagrant, docker and kind (Mac OS support)

Install vagrant for your platform:

```shell-script
https://www.vagrantup.com/downloads
```

To build the environment, including deploying the test cnf, do the following:

```shell-script
make vagrant-build
```

The kubeconfig for the new environment will override the file located at ~/.kube/config
Just start running commands from the command line to test the new cluster:

```shell-script
oc get pods -A
```

To destroy the vagrant environment, do the following:

```shell-script
make vagrant-destroy
```

To access the virtual machine supporting the cluster, do the following:

```shell-script
cd config/vagrant
user@fedora vagrant]$ vagrant ssh
[vagrant@k8shost ~]$
```

The partner repo scripts are located in ~/partner

## Setup with podman, qemu, and kind (Mac OS Ventura)

```sh
brew install kind podman qemu
kind create cluster
export KIND_EXPERIMENTAL_PROVIDER=podman
git clone git@github.com:test-network-function/cnf-certification-test-partner.git &&
  cd cnf-certification-test-partner &&
  make rebuild-cluster; make install
```

## License

CNF Certification Test Partner is copyright [Red Hat, Inc.](https://www.redhat.com) and available
under an
[Apache 2 license](https://github.com/test-network-function/cnf-certification-test-partner/blob/main/LICENSE).
