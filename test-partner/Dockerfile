FROM registry.access.redhat.com/ubi9/ubi:9.4-1214
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
		make \
		openssh-server \
		openssh-clients \
		podman \
		psmisc \
		wget \
	&& dnf clean all --assumeyes --disableplugin=subscription-manager \
	&& rm -rf /var/cache/yum

# Create user and group
RUN \
	groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Install Go binary and set the PATH
ENV \
	GO_DL_URL=https://golang.org/dl \
	GOPATH=/root/go
ENV GO_BIN_URL_x86_64=${GO_DL_URL}/go1.22.6.linux-amd64.tar.gz
ENV GO_BIN_URL_aarch64=${GO_DL_URL}/go1.22.6.linux-arm64.tar.gz

# Determine the CPU architecture and download the appropriate Go binary
# hadolint ignore=SC2086
RUN \
	if [ "$(uname -m)" = x86_64 ]; then \
		wget --directory-prefix=${TEMP_DIR} ${GO_BIN_URL_x86_64} --quiet \
		&& rm -rf /usr/local/go \
		&& tar -C /usr/local -xzf ${TEMP_DIR}/go1.22.6.linux-amd64.tar.gz; \
	elif [ "$(uname -m)" = aarch64 ]; then \
		wget --directory-prefix=${TEMP_DIR} ${GO_BIN_URL_aarch64} --quiet \
		&& rm -rf /usr/local/go \
		&& tar -C /usr/local -xzf ${TEMP_DIR}/go1.22.6.linux-arm64.tar.gz; \
	else \
		echo "CPU architecture is not supported." && exit 1; \
	fi

# Add go and oc binary directory to $PATH
ENV PATH="/bin/":"/usr/local/go/bin":${GOPATH}"/bin/":"${PATH}"

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
	&& echo "fake license" >> /licenses/LICENSE \
	&& echo ${PATH}
WORKDIR /app
COPY ./testapp /app/testapp
WORKDIR /app/testapp
RUN make build
ARG LIVENESS_PROBE_DEFAULT_PORT=8080
EXPOSE ${LIVENESS_PROBE_DEFAULT_PORT}

USER $USERNAME
CMD ["./bin/app"]
