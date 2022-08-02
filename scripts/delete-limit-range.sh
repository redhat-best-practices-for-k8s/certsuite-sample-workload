#!/usr/bin/env bash

oc delete --filename ./test-target/limit-range.yaml --namespace "$TNF_EXAMPLE_CNF_NAMES" --ignore-not-found
