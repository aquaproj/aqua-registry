FROM golang:1.22.1-bookworm
WORKDIR /workspace
ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
ENV AQUA_LOG_COLOR=always
ENV AQUA_POLICY_CONFIG=/workspace/aqua-policy.yaml
ENV PATH=$AQUA_ROOT_DIR/bin:/root/.cargo/bin:$PATH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y tree && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.3.0/aqua-installer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN echo "1577b99b74751a5ddeea757198cee3b600fce3ef18990540e4d0e667edcf1b5f  aqua-installer" | sha256sum -c
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.23.2-1
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
