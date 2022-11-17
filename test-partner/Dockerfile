FROM registry.access.redhat.com/ubi8/ubi:latest

ARG USERNAME=tnf-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN dnf install -y wget make hostname iproute iputils openssh openssh-clients podman psmisc ethtool

RUN groupadd --gid $USER_GID $USERNAME && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
USER $USERNAME

# Install Go binary
ENV GO_DL_URL="https://golang.org/dl"
ENV GO_BIN_TAR="go1.19.3.linux-amd64.tar.gz"
ENV GO_BIN_URL_x86_64=${GO_DL_URL}/${GO_BIN_TAR}
ENV GOPATH="/root/go"
RUN if [[ "$(uname -m)" -eq "x86_64" ]] ; then \
        wget --directory-prefix=${TEMP_DIR} ${GO_BIN_URL_x86_64} && \
            rm -rf /usr/local/go && \
            tar -C /usr/local -xzf ${TEMP_DIR}/${GO_BIN_TAR}; \
     else \
         echo "CPU architecture not supported" && exit 1; \
     fi

# Add go and oc binary directory to $PATH
ENV PATH="/bin/":"/usr/local/go/bin":${GOPATH}"/bin/":"${PATH}"

# Add arbitrary /licenses folder to pass preflight
RUN mkdir /licenses
RUN touch /licences/LICENSE

RUN echo ${PATH}

WORKDIR /app

COPY ./testapp /app/testapp

WORKDIR /app/testapp

RUN make build

ARG LIVENESS_PROBE_DEFAULT_PORT=8080

EXPOSE ${LIVENESS_PROBE_DEFAULT_PORT}

CMD ["./bin/app"]
