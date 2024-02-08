#!/usr/bin/env bash

# update docker config to include ipv6 support
jq '. +={"ipv6": true, "fixed-cidr-v6": "2001:db8:1::/64"}' /etc/docker/daemon.json > /tmp/new-docker-daemon.json
sudo cp /tmp/new-docker-daemon.json /etc/docker/daemon.json
rm /tmp/new-docker-daemon.json

# restart docker
sudo systemctl restart docker

# increase file system limits
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
