#!/usr/bin/env bash

oc delete daemonsets.apps/debug -n default
until [[ -z "$(oc get ds debug -n default 2>/dev/null)" ]]; do sleep 5; done
