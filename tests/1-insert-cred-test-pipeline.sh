#!/bin/bash
# Depends on credhub cli being installed

set -euo pipefail

ATTEMPT_COUNTER=0
MAX_ATTEMPTS=12
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

until $(curl -k --output /dev/null --silent --head --fail https://${HOSTNAME}:9000/info); do
    if [ ${ATTEMPT_COUNTER} -eq ${MAX_ATTEMPTS} ];then
      echo "Max attempts reached"
      exit 1
    fi
    ATTEMPT_COUNTER=$(let ${ATTEMPT_COUNTER}+1)
    CURRENT_TRY=$(let ${MAX_ATTEMPTS}-${ATTEMPT_COUNTER})
    echo "https://${HOSTNAME}:9000/info not online yet, ${CURRENT_TRY} more retries left"
    sleep 5
done

echo "Logging into Credhub"
credhub login -s https://${HOSTNAME}:9000 --client-name credhub_client --client-secret ${CREDHUB_CLIENT_SECRET} --skip-tls-validation

echo "Setting credential"
credhub set -n /concourse/main/hello -t value -v "from Credhub"

echo "Logging into Concourse"
fly login -t test -c http://localhost:8080 -u admin -p ${CONCOURSE_ADMIN_PASSWORD} -k

echo "Setting Pipeline"
fly -t test sp -p test -c ${SCRIPT_DIR}/pipeline-1.yml -n

echo "Unpausing pipeine"
fly -t test up -p test

echo "Triggering job"
fly -t test trigger-job -j test/job -w

echo "Deleting test pipeline"
fly -t test dp -p test -n

echo "Deleting test credential"
credhub delete -n /concourse/main/hello 