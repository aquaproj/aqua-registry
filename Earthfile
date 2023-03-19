VERSION 0.6
FROM golang:1.20.1-alpine3.17
WORKDIR /workspace

test:
	ENV AQUA_ROOT_DIR=/root/aquaproj-aqua
	RUN apk add curl bash
	RUN curl -sSfL -O https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.0.2/aqua-installer
	RUN echo "acbb573997d664fcb8df20a8a5140dba80a4fd21f3d9e606e478e435a8945208  aqua-installer" | sha256sum -c
	RUN chmod +x aqua-installer
	RUN ./aqua-installer -v v1.37.1
	COPY aqua/earthly-test.yaml aqua.yaml
	RUN echo "- import: pkg.yaml" >> aqua.yaml
	ARG pkg
	ARG os=linux
	ARG arch=amd64
	ENV AQUA_GOOS=$os
	ENV AQUA_GOARCH=$arch
	ENV AQUA_LOG_COLOR=always
	ENV PATH=$AQUA_ROOT_DIR/bin:$PATH
	COPY pkgs/$pkg/pkg.yaml pkg.yaml
	COPY pkgs/$pkg/registry.yaml registry.yaml
	RUN "$AQUA_ROOT_DIR/bin/aqua" i --test
