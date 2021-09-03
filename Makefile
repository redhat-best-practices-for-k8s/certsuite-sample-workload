.PHONY: install \
        clean

install: install-partner-pods 
	bash ./deploy-test-pods.sh

install-partner-pods:
	bash ./deploy-partner-pods.sh

install-operator-github:
	bash ./deploy-operator.sh

clean:
	bash ./clean-all.sh
