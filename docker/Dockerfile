FROM golang:1.21.4-bookworm
WORKDIR /workspace
ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
ENV AQUA_LOG_COLOR=always
ENV AQUA_POLICY_CONFIG=/workspace/aqua-policy.yaml
ENV PATH=$AQUA_ROOT_DIR/bin:$PATH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y tree && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.3/aqua-installer
RUN echo "11ac5e48901aba04dbb33d82c5a39c6cd69d3740312feb8c096f0aae86dc8ed5  aqua-installer" | sha256sum -c
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.16.5-2
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
