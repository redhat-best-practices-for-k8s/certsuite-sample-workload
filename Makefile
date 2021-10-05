.PHONY: 
	install \
  clean

# Deploys the partner and test pods and the operator
install:
	./scripts/deploy-partner-pods.sh
	./scripts/deploy-test-pods.sh
	./scripts/deploy-operator.sh

# creates a minikube instance	
rebuild-minikube:
	./scripts/deploy-minikube.sh

# deploys the partner pods
install-partner-pods:
	./scripts/deploy-partner-pods.sh

# Instal operator requires OLM and operator SDK
install-operator:
	./scripts/deploy-operator.sh

# deletes the namespace completely
clean-all:
	./scripts/clean-all.sh

# deletes, the partner and test pods and the operator
# pre-existing objects are preserved
clean:
	./scripts/clean.sh
