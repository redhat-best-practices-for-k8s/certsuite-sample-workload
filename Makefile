.PHONY:
	clean \
	create-statefulset \
	delete-deployment \
	install \
	install-litmus \
	install-prometheus

# Deploys the partner and test pods and the operator. GNU sed is required.
# MacOS has FreeBSD sed by default, which fails on --version.
install:
	sed --version >/dev/null 2>&1 || { printf >&2 'Install GNU sed.\n'; exit 1; }
	./scripts/fix-node-labels.sh
	./scripts/deploy-multus-network.sh
	./scripts/deploy-resource-quota.sh
	./scripts/deploy-storage.sh
	./scripts/deploy-test-pods.sh
	./scripts/deploy-statefulset-test-pods.sh
	./scripts/deploy-pod-disruption-budget.sh
	./scripts/deploy-test-crds.sh
	./scripts/install-olm.sh
	./scripts/deploy-community-operator.sh
	./scripts/manage-service.sh deploy
	./scripts/deploy-network-policies.sh
	./scripts/delete-standard-storageclass.sh
	./scripts/deploy-cr-scale-operator.sh

# Creates an install path specifically for the Kind QE clusters to use
install-for-qe:
	sed --version >/dev/null 2>&1 || { printf >&2 'Install GNU sed.\n'; exit 1; }
	./scripts/fix-node-labels.sh
	./scripts/deploy-multus-network.sh
	./scripts/install-olm.sh
	./scripts/delete-standard-storageclass.sh
	./scripts/deploy-cr-scale-operator.sh

# Bootstrap Docker (Fedora)
bootstrap-docker-fedora-local:
	cd config/vagrant/scripts && ./bootstrap-docker-fedora.sh

# Bootstrap Docker (Ubuntu)
bootstrap-docker-ubuntu-local:
	cd config/vagrant/scripts && ./bootstrap-docker-ubuntu.sh

# Bootstrap Python (Ubuntu)
bootstrap-python-ubuntu-local:
	cd config/vagrant/scripts && ./bootstrap-python-ubuntu.sh

# Bootstrap Python (Fedora)
bootstrap-python-fedora-local:
	cd config/vagrant/scripts && ./bootstrap-python-fedora.sh

# Bootstrap Golang (Fedora)
bootstrap-golang-fedora-local:
	cd config/vagrant/scripts && ./bootstrap-golang-fedora.sh

# Bootstrap Kubernetes/Kind
bootstrap-cluster:
	cd config/vagrant/scripts && ./bootstrap-cluster.sh

# Creates a k8s cluster instance
rebuild-cluster: delete-cluster
	./scripts/deploy-k8s-cluster.sh
	./scripts/preload-images.sh
	./scripts/deploy-calico.sh
	./scripts/delete-standard-storageclass.sh
	./scripts/remove-control-plane-taint.sh

# Creates a k8s cluster with a single worker
rebuild-cluster-single-worker: delete-cluster
	./scripts/deploy-k8s-cluster-single-worker.sh
	./scripts/preload-images.sh
	./scripts/deploy-calico.sh
	./scripts/delete-standard-storageclass.sh
	./scripts/remove-control-plane-taint.sh

delete-cluster:
	./scripts/delete-k8s-cluster.sh

# Launches Vagrant env.
vagrant-build:
	mkdir -p config/vagrant/kubeconfig
	vagrant plugin install vagrant-reload
	cd config/vagrant && vagrant up && cd -
	cp config/vagrant/kubeconfig/config ~/.kube/config

# Destroys Vagrant env
vagrant-destroy:
	cd config/vagrant && vagrant destroy

# Suspends the vagrant vm
vagrant-suspend:
	cd config/vagrant && vagrant suspend

# Resumes the vagrant vm
vagrant-resume:
	cd config/vagrant && vagrant resume

# Updates the vagrant vm
vagrant-update:
	cd config/vagrant && vagrant box update

# One command to recreate the environment
vagrant-recreate:
	cd config/vagrant && vagrant destroy -f
	make vagrant-build

# Installs operator requires OLM and operator SDK
install-operator:
	./scripts/deploy-operator.sh

install-community-operator:
	./scripts/deploy-community-operator.sh

delete-community-operator:
	./scripts/delete-community-operator.sh

# Installs test CRDs
install-crds:
	./scripts/deploy-test-crds.sh

install-litmus:
	./scripts/install-litmus-operator.sh

install-prometheus:
	./scripts/install-prometheus-operator.sh

delete-prometheus:
	./scripts/delete-prometheus-operator.sh

install-istio:
	./scripts/install-istio.sh

delete-istio:
	./scripts/delete-istio.sh

# Deletes deployment pods
delete-deployment:
	./scripts/delete-test-pods.sh

# Creates statefulset pods
create-statefulset:
	./scripts/deploy-statefulset-test-pods.sh

delete-litmus:
	./scripts/delete-litmus-operator.sh

# Deletes the namespace completely
clean-all:
	./scripts/clean-all.sh

# Deletes, the partner and test pods and the operator
# pre-existing objects are preserved
clean:
	./scripts/clean.sh

# Deploys services
deploy-services:
	./scripts/manage-service.sh deploy

# Deletes services
delete-services:
	./scripts/manage-service.sh delete

deploy-cr-scale-operator:
	./scripts/deploy-cr-scale-operator.sh

lint:
	shellcheck scripts/*.sh
