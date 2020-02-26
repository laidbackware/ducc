#!/bin/bash
# Build credhub docker image to store in local Docker cache

pushd /tmp
git clone https://github.com/cloudfoundry-incubator/credhub.git
pushd credhub
git checkout 2.5.x
git checkout origin/develop Dockerfile
docker build . -t credhub/credhub:local --rm
popd
rm -rf credhub