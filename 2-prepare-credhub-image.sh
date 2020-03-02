#!/bin/bash
# Build credhub docker image to store in local Docker cache

set -euxo pipefail

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1
echo "Temp dir is ${TMPDIR}"

pushd /${TMPDIR}
git clone https://github.com/cloudfoundry-incubator/credhub.git
pushd credhub
git checkout 2.5.x
git checkout 4617496 Dockerfile
sed -i 's/CN=localhost/CN=credhub/g' ./scripts/setup_dev_mtls.sh*
docker build . -t credhub/credhub:local-2.5 --rm
popd
rm -rf credhub