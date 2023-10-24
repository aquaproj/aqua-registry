FROM golang:1.21.3-bookworm
WORKDIR /workspace
ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
ENV AQUA_LOG_COLOR=always
ENV AQUA_POLICY_CONFIG=/workspace/aqua-policy.yaml
ENV PATH=$AQUA_ROOT_DIR/bin:$PATH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.2/aqua-installer
RUN echo "411caf1b5fcef4f5e74aa2a9fe99182ea13ab93ecd8ed4a983a7cff9f08edab9  aqua-installer" | sha256sum -c
RUN chmod +x aqua-installer
RUN ./aqua-installer -v v2.16.0
COPY aqua/earthly-test.yaml aqua.yaml
COPY aqua-policy.yaml aqua-policy.yaml
