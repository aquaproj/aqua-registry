VERSION 0.6
FROM golang:1.20.1-alpine3.17
WORKDIR /workspace

test:
	ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
	RUN apk add curl bash
	RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.1/aqua-installer
	RUN echo "c2af02bdd15da6794f9c98db40332c804224930212f553a805425441f8331665  aqua-installer" | sha256sum -c
	RUN chmod +x aqua-installer
	RUN ./aqua-installer -v v2.6.0
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
