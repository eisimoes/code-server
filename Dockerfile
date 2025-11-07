FROM golang:1.22.5-bookworm AS fixuid-builder

WORKDIR /tmp

RUN echo "**** Cloning fixuid repository ****" \
    && git clone https://github.com/boxboat/fixuid.git \
    && cd fixuid \
    && echo "**** Building fixuid" \
    && go build

FROM debian:trixie-slim

ARG CODE_RELEASE

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="VS Code in the browser"
LABEL org.opencontainers.image.authors="Eduardo Simoes <eisimoes@yahoo.com>"
LABEL org.opencontainers.image.version=${CODE_RELEASE}
LABEL org.opencontainers.image.documentation="https://github.com/eisimoes/code-server"
LABEL org.opencontainers.image.url="https://github.com/eisimoes/code-server"
LABEL org.opencontainers.image.source="https://github.com/eisimoes/code-server"

RUN : "${CODE_RELEASE:?The argument CODE_RELEASE is mandatory.}"

COPY --from=fixuid-builder /tmp/fixuid/fixuid /usr/bin/fixuid

RUN echo "**** Installing packages ****" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dumb-init \
        git \
        iproute2 \
        jq \
        openssh-client \
        python3 \
	python3-pip \
        python3-venv \
        python-is-python3 \
        sudo \
    && echo "**** Installing Code Server ****" \
    && curl -fsSL https://code-server.dev/install.sh | sh \
    && apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
    && echo "**** Finishing up configuration ****" \
    && adduser --gecos '' --disabled-password coder \
    && echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && mkdir -p /etc/fixuid \
    && printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml \
    && chmod a+s /usr/bin/fixuid \
    && mkdir -p /workspace \
    && chown coder.coder /workspace

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod a+x /usr/bin/entrypoint.sh

USER coder

WORKDIR /

EXPOSE 8080/tcp

ENV SHELL=/bin/bash

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["--bind-addr", "0.0.0.0:8080", "--auth", "none", "--disable-telemetry", "/workspace"]
