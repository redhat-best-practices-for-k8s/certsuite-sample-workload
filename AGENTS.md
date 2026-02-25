# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Repository Overview

This repository provides sample workloads and test infrastructure for the [certsuite](https://github.com/redhat-best-practices-for-k8s/certsuite) CNF certification test suite. It contains:

- **test-target/**: Kubernetes manifests for a sample CNF (deployment, statefulset, CRD, operator) that passes certsuite tests
- **test-partner/**: Debug pod Dockerfiles used for platform and networking tests
- **testapp/**: Simple Go web application providing health/readiness probe endpoints
- **scripts/**: Shell scripts for deploying/managing the test infrastructure
- **examples/**: YAML examples that intentionally fail specific certsuite test cases (for testing purposes)

## Common Commands

### Deploy Full Test Infrastructure
```bash
make install              # Deploy all test resources to cluster
make clean                # Remove test resources (preserves namespace)
make clean-all            # Remove entire namespace
```

### Kind Cluster Management
```bash
make rebuild-cluster      # Create new kind cluster with Calico CNI
make delete-cluster       # Delete kind cluster
```

### Specific Components
```bash
make install-operator     # Deploy the Hazelcast operator
make install-crds         # Deploy test CRDs
make install-prometheus   # Deploy Prometheus operator
make install-istio        # Deploy Istio service mesh
```

### Vagrant Environment (MacOS)
```bash
make vagrant-build        # Build and provision Vagrant VM with cluster
make vagrant-destroy      # Destroy Vagrant environment
make vagrant-recreate     # Destroy and rebuild
```

### Linting
```bash
make lint                 # Run shellcheck on all scripts
```

### Test Application
```bash
cd testapp && make build  # Build the testapp binary
```

## Architecture

### Deployment Flow
1. `make install` runs a sequence of scripts from `scripts/` that:
   - Fix node labels for test requirements
   - Deploy Multus CNI network attachments
   - Create storage (PV/PVC), resource quotas, pod disruption budgets
   - Deploy test pods (Deployment and StatefulSet)
   - Deploy CRDs and operators
   - Configure network policies

### Key Environment Variables
- `CERTSUITE_EXAMPLE_NAMESPACE`: Target namespace (default: `tnf`)
- `ON_DEMAND_DEBUG_PODS`: Deploy debug pods on-demand vs always (default: `true`)
- `CERTSUITE_PARTNER_REPO`: Container registry for debug images
- `MULTUS_IF_NUM`: Number of Multus interfaces to create

### Test Pod Characteristics
The test pods in `test-target/local-pod-under-test.yaml` are designed to pass certsuite checks by including:
- Non-root user security context
- Lifecycle hooks (preStop, postStart)
- Liveness/readiness/startup probes
- Pod anti-affinity rules
- Proper service account configuration
- Resource limits

### Template Processing
YAML files in `test-target/` use mustache-style templates (`{{ VAR }}`) that are processed by `scripts/mo` (a bash mustache implementation) during deployment.

## Container Images

- **certsuite-sample-workload**: Main test container with Go app (`test-partner/Dockerfile`)
- **debug-partner**: Debug pod image for platform tests (`test-partner/Dockerfile.debug-partner`)

Images are published to `quay.io/redhat-best-practices-for-k8s/`.

## Dependencies

- Kind (v0.30.0+) or OpenShift cluster
- kubectl/oc CLI
- Docker or Podman
- GNU sed (required for `make install`)
- shellcheck (for linting)
