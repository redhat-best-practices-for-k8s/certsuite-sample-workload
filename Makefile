.PHONY:
	install \
  clean

# Deploys the partner and test pods and the operator
install:
	./scripts/fix-minikube-labels.sh
	./scripts/deploy-test-pods.sh
	./scripts/deploy-hpa.sh
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

# deletes the namespace completely
clean-all:
	./scripts/clean-all.sh

# deletes, the partner and test pods and the operator
# pre-existing objects are preserved
clean:
	./scripts/clean.sh
