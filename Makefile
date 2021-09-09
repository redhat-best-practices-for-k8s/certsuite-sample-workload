.PHONY: install \
        clean

install: install-partner-pods 
	bash ./deploy-test-pods.sh

install-partner-pods:
	bash ./deploy-partner-pods.sh

install-operator-github:
	bash ./deploy-operator.sh

minikube:
	./create-local-registry.sh;
	./deploy-minikube.sh;\
	./deploy-test-pods.sh;\
	./deploy-partner-pods.sh;\
	./create-operator-bundle.sh;\
	./deploy-operator.sh

clean-all:
	bash ./clean-all.sh

clean:
	./clean.sh