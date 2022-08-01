#!/usr/bin/env bash

oc delete --filename ./test-target/resource-quota.yaml --namespace "$TNF_EXAMPLE_CNF_NAMES" --ignore-not-found
