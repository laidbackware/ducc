# Description
Pronounced Duck.
The goal of this project is the provide the simplest possible implementation of Concourse with Credhub secret management.

# Dependencies
Needed to start Concourse:
- docker-ce, plus the ability to run privileged containers
- docker-compose
- Your user in the docker group
- An internet connection
- (optional) direnv

The following CLI tools are needed to operate Concourse/Credhub/Minio and can be installed by the script detail in the setup process:
- Fly CLI - https://github.com/concourse/concourse/releases
- Credhub CLI - https://github.com/cloudfoundry-incubator/credhub-cli/releases
- Minio Client - https://min.io/download#/linux

# Setup Process
1. (Optional) Customize the vars in '1-vars.sh':
   - DUCC_HOSTNAME must be set to a IP or DNS entry be able to properly access the Concourse web page from another machine.
   - DUCC_MINIO_PATH should point to a persistent location to survive being torn down.
2. Export the environmental variables by either:
   1. Using direnv. On first use run 'direnv allow'
   2. Running 'source 1-vars.sh' to manually set the variables.
3. Run '2-prepare-credhub-image.sh' to build the credhub image and store it in the local docker cache.
4. Run one of the following:
   1. On first run use 'docker-compose up --abort-on-container-exit'  to ensure everything starts and check logs.
   2. To run in the background run 'docker-compose up -d'. Logs are available by running 'docker-compose logs' in the same directory as the docker-compose.yml file.
5. (Optional) Run '3-install-tools.sh' to install the necessary cli tools.
6. (Optional) To test all is well run tests/1-insert-cred-test-pipeline.sh

From now on standard docker-compose commands can be used to stop and start the deployment.

# Usage
 When accessing the Concourse webpage, the hostname in the '1-vars.sh' file  must be correct and used in the browser, as it is used by uaa for the callback.

Useful login commands:
- fly login -t main -c http://${DUCC_HOSTNAME}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -k
- credhub login -s https://${DUCC_HOSTNAME}:9000 --client-name credhub_client --client-secret ${DUCC_CREDHUB_CLIENT_SECRET} --skip-tls-validation
- mc config host add docker http://${DUCC_HOSTNAME}:9080 minio ${DUCC_MINIO_SECRET} --api "s3v4"

Concourse can be extended with features using the documentation and environmental variables in the docker-compose.yml file. For example LDAP authentication can be added using the documentation https://concourse-ci.org/ldap-auth.html

The Minio webpage is accessible on http://${DUCC_HOSTNAME}:9080 with username minio and the password from the .envrc.

# Running Offline
It's possible to run offline, but an internet connected system running Docker is required to prepare the images.
- The prepare credhub script must be run on the internet connected machine.
- All the Docker images must be pulled onto an internet connected machine and then use 'docker save' to generate a tar archive of each image. 
- Images should transported to the target Docker host and use 'docker load' to add images to the local Docker cache. 
- The docker-compose yaml should be updated to reflect the locally stored images. 

# Used Docker Images
At runtime
- concourse/concourse
- cfidentity/uaa
- minio/minio
- postgres
During the credhub build
- openjdk

# TODO
- Alter Docker build to set Java Keystore passwords 
- An official credhub image should be used when available which will hopefully fix the issue with the static passwords on the java keystores.
