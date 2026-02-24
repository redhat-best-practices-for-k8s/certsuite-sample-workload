# Build stage: Use official Go image to build the testapp
# This avoids QEMU emulation issues when extracting Go tarball during cross-platform builds
FROM docker.io/library/golang:1.26 AS builder
WORKDIR /app
COPY ./testapp /app/testapp
WORKDIR /app/testapp
RUN go build -o bin/app cmd/web/main.go

FROM registry.access.redhat.com/ubi9/ubi:9.7
ARG USERNAME=tnf-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# hadolint ignore=DL3041
RUN \
	dnf update --assumeyes --disableplugin=subscription-manager \
	&& dnf install --assumeyes --disableplugin=subscription-manager \
		ethtool \
		hostname \
		iproute \
		iputils \
		openssh-server \
		openssh-clients \
		podman \
		psmisc \
	&& dnf clean all --assumeyes --disableplugin=subscription-manager \
	&& rm -rf /var/cache/yum

# Create user and group
RUN \
	groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Configure SSH daemon
WORKDIR /home/${USERNAME}/sshd
RUN \
	printf 'Port 2222\nHostKey /home/%s/sshd/ssh_host_rsa_key\nPidFile /home/%s/sshd/sshd.pid\n' "$USERNAME" "$USERNAME" >> sshd_config \
	&& ssh-keygen -t rsa -f /home/${USERNAME}/sshd/ssh_host_rsa_key -N '' \
	&& chown -R $USERNAME:$USERNAME /home/${USERNAME}/sshd

# Add arbitrary /licenses folder to pass preflight
RUN \
	mkdir /licenses \
	&& touch /licenses/LICENSE \
	&& echo "fake license" >> /licenses/LICENSE

# Copy the pre-built binary from the builder stage
WORKDIR /app/testapp
COPY --from=builder /app/testapp/bin/app ./bin/app
ARG LIVENESS_PROBE_DEFAULT_PORT=8080
EXPOSE ${LIVENESS_PROBE_DEFAULT_PORT}

USER $USERNAME
CMD ["./bin/app"]
