#!/bin/bash
sudo dnf update -y
sudo dnf install -y python3 python3-pip
sudo pip3 install --upgrade pip

# Install the j2cli package for use with the multus-cni repo
sudo pip3 install j2cli
