FROM ubuntu:xenial

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV HELM_VERSION="v2.9.0"
ENV KUBECTL_VERSION="v1.13.0"

# gcc & python-dev are needed so we can install crcmod for gsutil
# also includes installations for Python3
RUN set -ex \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
    build-essential \
    curl \
    locales \
    wget \
    ca-certificates \
    git \
    zip \
    unzip \
    gcc \
    ssh \
    jq \
    python-dev \
    python-setuptools \
    python-pip \
    python3-dev \
    python3-setuptools \
    python3-pip \
    && python -V \
    && python3 -V \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

# Install docker.
RUN curl  https://get.docker.com/ | sh

RUN curl -LO curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl &&\
	chmod +x ./kubectl &&\
	mv ./kubectl /usr/local/bin/kubectl &&\
	wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm &&\
	chmod +x /usr/local/bin/helm &&\
	helm init --client-only


COPY checkout.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/checkout.sh

COPY run_workflows.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/run_workflows.sh

ENTRYPOINT ["/usr/local/bin/run_workflows.sh"]
