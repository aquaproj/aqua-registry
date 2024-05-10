FROM golang:1.22.3-bookworm@sha256:c2caf8c1c462dfa1cb58a7e8eb3e942d4013a90f42ad4ed2ac2517b37ed4bb8c
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  apt-get update && \
  apt-get install --no-install-recommends -y tree && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
ARG USERNAME=root
ARG GROUPNAME=root
ARG HOME=/root
RUN (id -u $USERNAME || useradd -m $USERNAME) && \
  (getent group $GROUPNAME || groupadd $GROUPNAME)
USER $USERNAME
WORKDIR $HOME
ENV AQUA_ROOT_DIR=$HOME/aquaproj-aqua
ENV AQUA_LOG_COLOR=always
ENV AQUA_POLICY_CONFIG=$HOME/aqua-policy.yaml
ENV PATH=$AQUA_ROOT_DIR/bin:$HOME/.cargo/bin:$PATH
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.0.1/aqua-installer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
RUN echo "fb4b3b7d026e5aba1fc478c268e8fbd653e01404c8a8c6284fdba88ae62eda6a  aqua-installer" | sha256sum -c
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.27.4
COPY aqua-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
WORKDIR /workspace
