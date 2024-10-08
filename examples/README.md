<!-- markdownlint-disable line-length no-bare-urls -->
# YAML Examples

This folder is going to house some example YAMLs that will make the test suite fail if applied to a cluster.  Not all test suites have an example to show but more examples can be added in the future.

Please refer to the [CATALOG](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md) for more information about the examples and how they affect the test suite's results.

## Examples by Test Suite

Please find an example below that ties to a specific test case you are interested in.

### accesscontrol

* [cluster-role-bindings](accesscontrol/clusterRoleBinding.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-cluster-role-bindings)

Creates necessary cluster role, role binding, service account, and pod that causes a failure in the `accesscontrol` suite of tests because the rolebinding cannot cross namespaces.

* [host-resource (host-port)](accesscontrol/hostPortPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-container-host-port)
* [host-resource (ipc-lock)](accesscontrol/ipcLockPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-ipc-lock-capability-check)
* [host-resource (net-admin)](accesscontrol/netAdminPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-net-admin-capability-check)
* [host-resource (net-raw)](accesscontrol/netRawPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-net-raw-capability-check)
* [host-resource (sys-admin)](accesscontrol/sysAdminPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-sys-admin-capability-check)

* namespace (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-namespace)

* [pod-automount-service-account-token](accesscontrol/serviceAccountTokenPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-pod-automount-service-account-token)

* [pod-role-bindings](accesscontrol/podRoleBinding.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-pod-role-bindings)

Creates necessary role, role binding, service account, and pod that causes a failure in the `accesscontrol` suite of tests because the rolebinding cannot cross namespaces.

* [pod-service-account](accesscontrol/serviceAccountPod.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-pod-service-account)

### affiliated-certification

No examples to show (yet)…

* container-is-certified (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#affiliated-certification-container-is-certified-digest)
* operator-is-certified (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#affiliated-certification-operator-is-certified)

### lifecycle

Note: We might need the following flag set in the environment in which you are testing these YAMLs to avoid any draining, cluster-intrusive issues, etc.
`export CERTSUITE_NON_INTRUSIVE_ONLY=true`

* [container-shutdown (prestop)](lifecycle/preStop.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-container-prestop)

Creates a pod without a lifecycle.preStop defined that will cause a failure with this test suite.

* deployment-scaling (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-deployment-scaling)

* [image-pull-policy](lifecycle/imagePullPolicy.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-image-pull-policy)

Image in this pod has a pull policy of 'Always' which is incorrect.

Creates a pod without a terminationGracePeriod set correctly.

* [pod-high-availability](lifecycle/highAvailability.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-pod-high-availability)

Creates a deployment with a replica count of 2 but with no pod anti affinity rules.

* [pod-owner-type](lifecycle/podOwnerType.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-pod-owner-type)

Creates a pod with no "owner".  It does not belong to a replicaset or a deployment.

* pod-recreation (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-pod-recreation)

* pod-scheduling (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-pod-scheduling)

* stateful-scaling (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#lifecycle-statefulset-scaling)

### networking

* icmpv4-connectivity (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#networking-icmpv4-connectivity)

* icmpv4-connectivity-multus (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#networking-icmpv4-connectivity-multus)

* [service-type (nodeport check)](networking/nodeport.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#access-control-service-type)

Creates a service in the cluster that uses type nodePort.  The test suite ensures that no services with nodePort are created.

### observability

* [container-logging](observability/logging.yaml) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#observability-container-logging)

Creates an `echo-server` pod which does some logging to the stdout.  The test checks if stdout is available to pass.  This is sort of an anti-test.  Any pod created that doesn't log to stdout/stderr would fail.

* crd-status (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#observability-crd-status)

### operator

* install-source (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#operator-install-source)
* install-status (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#operator-install-status-no-privileges)

### platform-alteration

* base-image (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-base-image)
* boot-params (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-boot-params)
* hugepages-config (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-hugepages-config)
* isredhat-release (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-isredhat-release)
* sysctl-config (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-sysctl-config)
* tainted-node-kernel (no example) - [Catalog Link](https://github.com/redhat-best-practices-for-k8s/certsuite/blob/main/CATALOG.md#platform-alteration-tainted-node-kernel)
