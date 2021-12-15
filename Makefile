.PHONY:
	install \
  clean \
  delete-deployment \
  creat-statefulset

# Deploys the partner and test pods and the operator
install:
	./scripts/fix-minikube-labels.sh
	./scripts/deploy-multus-network.sh
	./scripts/deploy-test-pods.sh
	./scripts/deploy-operator.sh
	./scripts/deploy-test-crds.sh
	./scripts/deploy-debug-ds.sh

# creates a minikube instance
rebuild-minikube:
	./scripts/deploy-minikube.sh

# deploys the partner pods
install-partner-pods:
	./scripts/deploy-debug-ds.sh
	
# Instal operator requires OLM and operator SDK
install-operator:
	./scripts/deploy-operator.sh

# Install test CRDs
install-crds:
	./scripts/deploy-test-crds.sh

# delete deployment pods
delete-deployment:
	./scripts/delete-test-pods.sh

# create statefulset pods
creat-statefulset:
	./scripts/deploy-statefulset-test-pods.sh

# deletes the namespace completely
clean-all:
	./scripts/clean-all.sh

# deletes, the partner and test pods and the operator
# pre-existing objects are preserved
clean:
	./scripts/clean.sh

