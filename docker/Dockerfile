FROM mirror.gcr.io/golang:1.26.2-trixie
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
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/b8be739961814ee66b9e0d505f4d5de0d2eff047/aqua-installer # v4.1.2
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.66.1
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
