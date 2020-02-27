#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

CREDHUB_CLI_VERSION=2.7.0
FLY_CLI_VERSION=$(cat docker-compose.yml |grep "image: concourse/concourse" | cut -d ":" -f3)

OS=$(echo "$(uname -s)" | awk '{print tolower($0)}')

# Replace fly if the version does not match the docker image
if ! command -v fly || [ $(fly -v) != ${FLY_CLI_VERSION} ]; then
    wget -O /tmp/fly.tgz https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-${OS}-amd64.tgz
    tar xvfz /tmp/fly.tgz -C/tmp/
    rm /tmp/fly.tgz
    chmod +x /tmp/fly
    mv /tmp/fly /usr/local/bin/
fi
echo "Fly version $(fly -v)"

if ! command -v mc; then
    wget -O /tmp/mc https://dl.min.io/client/mc/release/${OS}-amd64/mc
    chmod +x /tmp/mc
    mv /tmp/mc /usr/local/bin/
fi
echo "$(mc -v)"

if ! command -v credhub; then
    wget -O /tmp/credhub.tgz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-${OS}-${CREDHUB_CLI_VERSION}.tgz
    tar xvfz /tmp/credhub.tgz -C/tmp/
    rm /tmp/credhub.tgz
    chmod +x /tmp/credhub
    mv /tmp/credhub /usr/local/bin/
fi
echo "$(credhub --version)"
