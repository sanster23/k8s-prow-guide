FROM ubuntu:xenial

# Install all the relevant packages
RUN set -xe \
  && apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
  build-essential \
  curl \
  wget \
  git \
  python3-dev \
  python3-setuptools \
  python3-pip \
  && python3 -V \
  && apt-get clean

  # Install Helm
  RUN wget -O /tmp/get_helm.sh \
      https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get && \
      chmod 700 /tmp/get_helm.sh && \
      /tmp/get_helm.sh && \
      rm /tmp/get_helm.sh

# Initialize helm
RUN helm init --client-only

# Install docker.
RUN curl  https://get.docker.com/ | sh

# Install kubectl
RUN  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl && \
  mv kubectl /usr/local/bin && \
  chmod a+x /usr/local/bin/kubectl


COPY checkout.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/checkout.sh

COPY entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
