#!/bin/bash
sudo dnf update -y
echo "192.168.56.10  k8shost" >> /etc/hosts

# Adding docker repository
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

# Remove old docker packages
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

# Install docker
sudo dnf -y install dnf-plugins-core
sudo dnf -y install docker-ce docker-ce-cli containerd.io jq

# Configure IPv6 in docker ( https://docs.docker.com/config/daemon/ipv6/ )
sudo mkdir /etc/docker

# Create the daemon.json file if it does not exist
sudo touch -a /etc/docker/daemon.json

sudo bash -c 'cat <<- EOF > /etc/docker/daemon.json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF'

# Enable IPv6 
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0

# Persist IPv6
sudo bash -c 'cat <<- EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
EOF'

# Increase limits
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512

# Persist limits
sudo bash -c 'cat <<- EOF >> /etc/sysctl.conf
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
EOF'

# disable firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# start docker
sudo systemctl restart docker.service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Perform the post install ( https://docs.docker.com/engine/install/linux-postinstall )
sudo groupadd docker
sudo usermod -aG docker "$USER"

# ensures docker is running
#STATE=""
#while [ "$STATE" != $'CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES' ]; do
#  STATE=$(docker ps)
#  sleep 1
#done
#echo "docker service is running"
