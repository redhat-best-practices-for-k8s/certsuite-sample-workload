.PHONY: install \
        clean

install:
	oc create -f local-test-infra/local-partner-pod.yaml
	oc create -f local-test-infra/local-pod-under-test.yaml

clean:
	oc delete -f local-test-infra/local-partner-pod.yaml
	oc delete -f local-test-infra/local-pod-under-test.yaml
