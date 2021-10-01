.PHONY: 
	install \
  clean

install:
	./scripts/deploy-partner-pods.sh
	./scripts/deploy-test-pods.sh
	./scripts/deploy-operator.sh
minikube:
	./scripts/deploy-minikube.sh

install-partner-pods:
	./scripts/deploy-partner-pods.sh

# Instal operator requires OLM and operator SDK
install-operator:
	./scripts/deploy-operator.sh

clean-all:
	./scripts/clean-all.sh

clean:
	./scripts/clean.sh
