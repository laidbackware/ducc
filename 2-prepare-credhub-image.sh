#!/bin/bash
# Build credhub docker image to store in local Docker cache

set -euxo pipefail
SCRIPT_DIR=$(pwd)

pushd /tmp
git clone https://github.com/cloudfoundry-incubator/credhub.git
pushd credhub
git checkout 2.5.x
git checkout 4617496 Dockerfile
docker build . -t credhub/credhub:local-2.5 --rm
popd
rm -rf credhub