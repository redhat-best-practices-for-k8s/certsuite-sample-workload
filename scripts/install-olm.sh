#!/usr/bin/env bash
set -x

# Install OLM
operator-sdk olm uninstall
operator-sdk olm install