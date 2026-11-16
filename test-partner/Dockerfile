# Build stage: source-built podman, same approach as Dockerfile.debug-partner.
# podman cannot be installed from RPMs right now: UBI 9 publishes
# netavark-3:1.17.2-3.el9, which requires aardvark-dns >= 3:1.17 (epoch 3), but
# the only aardvark-dns published is 2:1.17.1-1.el9_8 (epoch 2), so the dnf
# transaction has no resolvable solution. Build the binary instead and drop the
# RPM install once the UBI epochs line up.
# IMPORTANT: podman must be built from ubi8.x only. Do not upgrade it to ubi9.
FROM registry.access.redhat.com/ubi8/ubi:8.10-1304.1751400627 as podman-builder
# hadolint ignore=DL3041
RUN \
	dnf update --assumeyes --disableplugin=subscription-manager \
	&& dnf install --assumeyes --disableplugin=subscription-manager \
		git \
		make \
		golang \
		gpgme-devel \
		libseccomp-devel \
		libassuan-devel \
		python3 \
	&& dnf clean all \
	&& git clone https://github.com/containers/podman.git
WORKDIR /podman
RUN \
	git checkout v4.9.5 \
	&& make

# Build stage: Use official Go image to build the testapp
# This avoids QEMU emulation issues when extracting Go tarball during cross-platform builds
FROM docker.io/library/golang:1.27 AS builder
WORKDIR /app
COPY ./testapp /app/testapp
WORKDIR /app/testapp
RUN go build -o bin/app cmd/web/main.go

FROM registry.access.redhat.com/ubi9/ubi:9.9
# hadolint ignore=DL3064
ARG USERNAME=tnf-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# NOTE: podman is not in this dnf transaction; it is copied from the
# podman-builder stage below because the UBI 9 RPM dependency chain is broken
# (see the comment on that stage).
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
		psmisc \
		util-linux \
	&& dnf clean all --assumeyes --disableplugin=subscription-manager \
	&& rm -rf /var/cache/yum

# Install the source-built podman on PATH. It has to live outside /root because
# the workload runs as the unprivileged $USERNAME user.
COPY --from=podman-builder /podman/bin/podman /usr/local/bin/podman
RUN chmod 0755 /usr/local/bin/podman

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

# hadolint ignore=DL3066
USER $USERNAME
CMD ["./bin/app"]
