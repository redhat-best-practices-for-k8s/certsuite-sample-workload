<!-- markdownlint-disable line-length no-bare-urls -->
# YAML Examples

This folder is going to house some example YAMLs that will make the test suite fail if applied to a cluster.  Not all test suites have an example to show but more examples can be added in the future.

Please refer to the [CATALOG](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md) for more information about the examples and how they affect the test suite's results.

## Examples by Test Suite

Please find an example below that ties to a specific test case you are interested in.

### accesscontrol

* [cluster-role-bindings](examples/accesscontrol/clusterRoleBinding.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#cluster-role-bindings)

Creates necessary cluster role, role binding, service account, and pod that causes a failure in the `accesscontrol` suite of tests because the rolebinding cannot cross namespaces.

* [host-resource (host-port)](examples/accesscontrol/hostPortPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#host-resource)
* [host-resource (ipc-lock)](examples/accesscontrol/ipcLockPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#host-resource)
* [host-resource (net-admin)](examples/accesscontrol/netAdminPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#host-resource)
* [host-resource (net-raw)](examples/accesscontrol/netRawPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#host-resource)
* [host-resource (sys-admin)](examples/accesscontrol/sysAdminPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#host-resource)

* namespace (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#namespace)

* [pod-automount-service-account-token](examples/accesscontrol/serviceAccountTokenPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-automount-service-account-token)

* [pod-role-bindings](examples/accesscontrol/podRoleBinding.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-role-bindings)

Creates necessary role, role binding, service account, and pod that causes a failure in the `accesscontrol` suite of tests because the rolebinding cannot cross namespaces.

* [pod-service-account](examples/accesscontrol/serviceAccountPod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-service-account)

### affiliated-certification

No examples to show (yet)…

* container-is-certified (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#container-is-certified)
* operator-is-certified (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#operator-is-certified)

### lifecycle

Note: We might need the following flag set in the environment in which you are testing these YAMLs to avoid any draining, cluster-intrusive issues, etc.
`export CERTSUITE_NON_INTRUSIVE_ONLY=true`

* [container-shutdown (prestop)](examples/lifecycle/preStop.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#container-shutdown)

Creates a pod without a lifecycle.preStop defined that will cause a failure with this test suite.

* deployment-scaling (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#deployment-scaling)

* [image-pull-policy](examples/lifecycle/imagePullPolicy.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#image-pull-policy)

Image in this pod has a pull policy of 'Always' which is incorrect.

* [pod-termination-grace-period](examples/lifecycle/terminationGracePeriod.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-termination-grace-period)

Creates a pod without a terminationGracePeriod set correctly.

* [pod-high-availability](examples/lifecycle/highAvailability.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-high-availability)

Creates a deployment with a replica count of 2 but with no pod anti affinity rules.

* [pod-owner-type](examples/lifecycle/podOwnerType.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-owner-type)

Creates a pod with no "owner".  It does not belong to a replicaset or a deployment.

* pod-recreation (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-recreation)

* pod-scheduling (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#pod-scheduling)

* stateful-scaling (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#statefulset-scaling)

### networking

* icmpv4-connectivity (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#icmpv4-connectivity)

* icmpv4-connectivity-multus (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#icmpv4-connectivity-multus)

* [service-type (nodeport check)](examples/networking/nodeport.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#service-type)

Creates a service in the cluster that uses type nodePort.  The test suite ensures that no services with nodePort are created.

### observability

* [container-logging](examples/observability/logging.yaml) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#container-logging)

Creates an `echo-server` pod which does some logging to the stdout.  The test checks if stdout is available to pass.  This is sort of an anti-test.  Any pod created that doesn't log to stdout/stderr would fail.

* crd-status (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#crd-status)

### operator

* install-source (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#install-source)
* install-status (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#install-status)

### platform-alteration

* base-image (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#base-image)
* boot-params (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#boot-params)
* hugepages-config (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#hugepages-config)
* isredhat-release (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#isredhat-release)
* sysctl-config (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#sysctl-config)
* tainted-node-kernel (no example) - [Catalog Link](https://github.com/test-network-function/cnf-certification-test/blob/main/CATALOG.md#tainted-node-kernel)
