FROM golang:1.22.2-bookworm@sha256:48b942a5a9803fafeb748f1a9c6edeb71e06653bb4df25f63f909151e15e9618
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
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.0.0/aqua-installer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN echo "8299de6c19a8ff6b2cc6ac69669cf9e12a96cece385658310aea4f4646a5496d  aqua-installer" | sha256sum -c
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.27.3
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
