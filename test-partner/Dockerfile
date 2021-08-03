FROM registry.access.redhat.com/ubi7/ubi:latest

RUN yum install -y hostname iproute iputils openssh openssh-clients podman
COPY diff-fs.sh /diff-fs.sh

CMD ["tail", "-f", "/dev/null"]
