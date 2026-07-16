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
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v4.0.5/aqua-installer
RUN echo "451028d56959cc738564885b1dbebc2691ea038ffde04e2472e4d486a3591146  aqua-installer" | sha256sum -c -
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.62.0
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
