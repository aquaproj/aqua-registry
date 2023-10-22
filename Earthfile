VERSION 0.6
FROM golang:1.21.3-bookworm
WORKDIR /workspace

test:
	ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
	RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.2/aqua-installer
	RUN echo "411caf1b5fcef4f5e74aa2a9fe99182ea13ab93ecd8ed4a983a7cff9f08edab9  aqua-installer" | sha256sum -c
	RUN chmod +x aqua-installer
	RUN ./aqua-installer -v v2.16.0
	COPY aqua/earthly-test.yaml aqua.yaml
	COPY aqua-policy.yaml aqua-policy.yaml
	RUN echo "- import: pkg.yaml" >> aqua.yaml
	ARG pkg
	ARG os=linux
	ARG arch=amd64
	ENV AQUA_GOOS=$os
	ENV AQUA_GOARCH=$arch
	ENV AQUA_LOG_COLOR=always
	ENV AQUA_POLICY_CONFIG=/workspace/aqua-policy.yaml
	ENV PATH=$AQUA_ROOT_DIR/bin:$PATH
	COPY pkgs/$pkg/pkg.yaml pkg.yaml
	COPY pkgs/$pkg/registry.yaml registry.yaml
	RUN "$AQUA_ROOT_DIR/bin/aqua" i --test
