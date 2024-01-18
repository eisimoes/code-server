FROM golang:1.21-bookworm AS fixuid-builder

WORKDIR /tmp

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=True

RUN echo "**** Cloning fixuid repository ****" \
    && git clone https://github.com/boxboat/fixuid.git \
    && cd fixuid \
    && echo "**** Building fixuid" \
    && go build

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=True

ARG CODE_RELEASE

ENV NODE_GYP_FORCE_PYTHON=/usr/bin/python3

LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="VS Code in the browser"
LABEL org.opencontainers.image.authors="Eduardo Simoes <eisimoes@yahoo.com>"
LABEL org.opencontainers.image.version=${CODE_RELEASE}
LABEL org.opencontainers.image.documentation="https://github.com/eisimoes/code-server"
LABEL org.opencontainers.image.url="https://github.com/eisimoes/code-server"
LABEL org.opencontainers.image.source="https://github.com/eisimoes/code-server"

RUN : "${CODE_RELEASE:?The argument CODE_RELEASE is mandatory.}"

COPY --from=fixuid-builder /tmp/fixuid/fixuid /usr/bin/fixuid

RUN echo "**** Setting up repositories ****" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        -o /etc/apt/trusted.gpg.d/nodesource.asc \
    && echo 'deb https://deb.nodesource.com/node_18.x nodistro main' \
        > /etc/apt/sources.list.d/nodesource.list \
    && printf 'Package: *\nPin: origin deb.nodesource.com\nPin-Priority: 1001' \
        > /etc/apt/preferences.d/nodesource \
    && echo "**** Installing build dependencies ****" \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        libatomic1 \
        libsecret-1-0 \
        libsecret-1-dev \
        libkrb5-dev \
        pkg-config \
    && echo "**** Installing packages ****" \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        git \
        iproute2 \
        jq \
        nodejs \
        openssh-client \
        python3 \
	python3-pip \
        python3-venv \
        python-is-python3 \
        sudo \
    && echo "**** Installing Code Server ****" \
    && npm install --global code-server --unsafe-perm --legacy-peer-deps --maxsockets 1 \
    && echo "**** Cleaning up ****" \
    && apt-get purge --auto-remove -y \
        build-essential \
        libsecret-1-dev \
        libkrb5-dev \
        pkg-config \
    && npm cache clean -force \
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

EXPOSE 8443/tcp

ENV SHELL=/bin/bash

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["--bind-addr", "0.0.0.0:8080", "--auth", "none", "--disable-telemetry", "/workspace"]
