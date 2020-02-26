# ducc
ducc - Docker-compose + UAA + Concourse + Credhub

# Env vars
These must be consistent and are required to restart ducc.

export HOSTNAME=192.168.0.3 # Can be IP or hostname 
export ENCRYPTION_PASSWORD=password1234 
export CONCOURSE_ADMIN_PASSWORD=test 
export CREDHUB_CLIENT_SECRET=secret 
export POSTGRES_PASSWORD=password 
export TRUST_STORE_PASSWORD=changeit # Cannot be changed currently

# Process
1. Run '1-prepare-credhub-image.sh' to build the credhub image and store in local docker cache
2. Export each of the environmental variables
3. Run one of the following
   1. On first run use 'docker-compose up --abort-on-container-exit'  to ensure everything starts and check logs
   2. To run in the background run 'docker-compose up -d'. Logs are available by using 'docker-compose logs'
4. (Optional) To test all is well run tests/1-insert-cred-test-pipeline.sh

# TODO
- Alter Docker build to set Java Keystore passwords 
- An official credhub image should be used when available which will hopefully fix the issue with the static passwords on the java keystores.
