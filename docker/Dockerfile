# Basic setup for Prow jobs

FROM debian:stretch

ENV GO_VERSION=1.12.5 \
    DOCKER_VERSION=18.06.1* \
    GOLANGCI_VERSION="v1.16.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    dnsutils \
    openssh-client \
    python \
    wget \
    apt-transport-https \
    gnupg2 \
    shellcheck \
    software-properties-common \
    lsb-release \
    && apt-get clean

# Docker-in-docker
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
    | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) stable"

RUN apt-get update && \
    apt-get install -y --no-install-recommends docker-ce=${DOCKER_VERSION} && \
    sed -i 's/cgroupfs_mount$/#cgroupfs_mount\n/' /etc/init.d/docker

# Move Docker's storage location
RUN echo 'DOCKER_OPTS="${DOCKER_OPTS} --data-root=/docker-graph"' | \
    tee --append /etc/default/docker
RUN mkdir /docker-graph


# Install Go
RUN wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    mv go /usr/local

ENV GOPATH /home/prow/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p ${GOPATH}/bin && \
    mkdir -p ${GOPATH}/src

# Install GolangCi-lint
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b "$GOPATH"/bin "$GOLANGCI_VERSION"

# Install go cover tool
RUN go get golang.org/x/tools/cmd/cover

COPY ci-runner.sh /ci-runner.sh
RUN chmod +x /ci-runner.sh