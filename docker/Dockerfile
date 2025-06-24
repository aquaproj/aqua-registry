FROM golang:1.24.4-bookworm
WORKDIR /workspace
ENV AQUA_LOG_COLOR=always
ENV AQUA_POLICY_CONFIG=/workspace/aqua-policy.yaml
ENV PATH=/root/.local/share/aquaproj-aqua/bin:/root/.cargo/bin:$PATH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y tree && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v4.0.1/aqua-installer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN echo "f7fa69dacb234ce9648f3008cef9120a1e59d96c37971e747668c0fada7bec68  aqua-installer" | sha256sum -c -
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.53.3
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
