FROM ubuntu:22.04

ARG TARGETARCH
ARG RUNNER_VERSION=2.321.0

# The runner binary is a .NET app; skip its ICU dependency entirely instead of
# chasing libicu package names across Ubuntu releases.
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates tar jq git sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m runner \
    && echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner

WORKDIR /home/runner/actions-runner

RUN case "${TARGETARCH}" in \
        "amd64") RUNNER_ARCH="x64" ;; \
        "arm64") RUNNER_ARCH="arm64" ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSLo runner.tar.gz \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" \
    && tar xzf runner.tar.gz \
    && rm runner.tar.gz \
    && ./bin/installdependencies.sh

RUN chown -R runner:runner /home/runner

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
