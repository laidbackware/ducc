# Description
Pronounced Duck.
The goal of this project is the provide the simplest possible implementation of Concourse with Credhub secret management.

# Dependencies
- docker-ce, plus the ability to run privileged containers
- docker-compose
- Your user in the docker group
- An internet connection
- (optional) direnv

# Setup Process
1. Customize the vars in .envrc if needed. This file is ignored by git but should be kept as the secrets cannot be changed.
2. Run '1-prepare-credhub-image.sh' to build the credhub image and store it in the local docker cache.
3. Export the environmental variables by either:
   1. Using direnv. On first use run 'direnv allow .'
   2. Running 'source .envrc' to manually set the variables
4. Run one of the following
   1. On first run use 'docker-compose up --abort-on-container-exit'  to ensure everything starts and check logs
   2. To run in the background run 'docker-compose up -d'. Logs are available by using 'docker-compose logs'
5. (Optional) To test all is well run tests/1-insert-cred-test-pipeline.sh

# Usage
 When accessing the Concourse webpage the hostname in the .envrc must be correct and used in the browser, as it is used by uaa for the callback.

Useful login commands:
- fly login -t main -c http://${HOSTNAME}:8080 -u admin -p ${CONCOURSE_ADMIN_PASSWORD} -k
- credhub login -s https://${HOSTNAME}:9000 --client-name credhub_client --client-secret ${CREDHUB_CLIENT_SECRET} --skip-tls-validation
- mc config host add docker http://${HOSTNAME}:9080 minio ${MINIO_SECRET} --api "s3v4"

Concourse can be extended with features using the documentation and environmental variables. For example LDAP authentication can be configured.

The Minio webpage is accessible on http://${HOSTNAME}:9080 with username minio and the password from the .envrc.

# Running Offline
It's possible to run offline, but an internet connected system running Docker is required to prepare the images.
- The prepare credhub script must be run on the internet connected machine.
- All the Docker images must be pulled onto an internet connected machine and then use 'docker save' to generate a tar archive of each image. 
- Images should transported to the target Docker host and use 'docker load' to add images to the local Docker cache. 
- The docker-compose yaml should be updated to reflect the locally stored images. 

# TODO
- Alter Docker build to set Java Keystore passwords 
- An official credhub image should be used when available which will hopefully fix the issue with the static passwords on the java keystores.
