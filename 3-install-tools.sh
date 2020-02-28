#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1
echo "Temp dir is ${TMPDIR}"


CREDHUB_CLI_VERSION=2.7.0
FLY_CLI_VERSION=$(cat docker-compose.yml |grep "image: concourse/concourse" | cut -d ":" -f3)

OS=$(echo "$(uname -s)" | awk '{print tolower($0)}')

# Replace fly if the version does not match the docker image
if ! command -v fly || [ $(fly -v) != ${FLY_CLI_VERSION} ]; then
    wget -O ${TMPDIR}/fly.tgz https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-${OS}-amd64.tgz
    tar xvfz ${TMPDIR}/fly.tgz -C${TMPDIR}/
    rm ${TMPDIR}/fly.tgz
    chmod +x ${TMPDIR}/fly
    mv ${TMPDIR}/fly /usr/local/bin/
fi
echo "Fly version $(fly -v)"

if ! command -v mc; then
    wget -O ${TMPDIR}/mc https://dl.min.io/client/mc/release/${OS}-amd64/mc
    chmod +x ${TMPDIR}/mc
    mv ${TMPDIR}/mc /usr/local/bin/
fi
echo "$(mc -v)"

if ! command -v credhub; then
    wget -O ${TMPDIR}/credhub.tgz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-${OS}-${CREDHUB_CLI_VERSION}.tgz
    tar xvfz ${TMPDIR}/credhub.tgz -C${TMPDIR}/
    rm ${TMPDIR}/credhub.tgz
    chmod +x ${TMPDIR}/credhub
    mv ${TMPDIR}/credhub /usr/local/bin/
fi
echo "$(credhub --version)"
