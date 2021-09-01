.PHONY: install \
        clean

install: install-partner-pods 
	bash ./deploy-test-pods.sh
	bash ./deploy-operator.sh

install-partner-pods:
	bash ./deploy-partner-pods.sh

install-operator:
	bash ./deploy-operator.sh

clean:
	bash ./clean-all.sh
