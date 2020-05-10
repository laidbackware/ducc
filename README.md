# Description
Pronounced Duck.
The goal of this project is the provide the simplest possible implementation of Concourse with Credhub secret management.

# Dependencies
Needed to start Concourse:
- docker-ce, plus the ability to run privileged containers
- docker-compose
- Your user in the docker group
- An internet connection or the required images in the local Docker cache
- (optional) direnv

The following CLI tools are needed to operate Concourse/Credhub/Minio and can be installed by the script detailed in the setup process:
- Fly CLI - https://github.com/concourse/concourse/releases
- Credhub CLI - https://github.com/cloudfoundry-incubator/credhub-cli/releases
- Minio Client - https://min.io/download#/linux

# Setup Process
1. Customize the vars in '1-vars.sh':
   - `DUCC_HOSTNAME` must be set to a IP or DNS entry for credhub integration to work.
   - (option) `DUCC_MINIO_PATH` should point to a persistent location to survive being torn down.
   - (option) `DUCC_CONCOURSE_ADMIN_PASSWORD`, `DUCC_CREDHUB_CLIENT_SECRET` and `DUCC_MINIO_SECRET` can be changed at any time
   - (option) `DUCC_ENCRYPTION_PASSWORD` and `DUCC_POSTGRES_PASSWORD` are setup on first use and cannot be changed.
2. Export the environmental variables by either:
   1. If using direnv run `direnv allow` within the directory.
   2. Running `source 1-vars.sh` to manually set the variables.

4. To run in the background run `docker-compose up -d`. 
      Logs are available by running `docker-compose logs` in the same directory as the docker-compose.yml file. `docker-compose ps` can be use to check the state of the containers.
5. (Optional) Run `2-install-tools.sh` to install the necessary cli tools.
6. (Optional) To test all is well run `tests/1-insert-cred-test-pipeline.sh`.

From now on standard docker-compose commands can be used to stop and start the deployment.

# Usage
When accessing the Concourse webpage, the hostname in the `1-vars.sh` file  must be correct and used in the web browser, as it is used by Concourse when authenticating.

Useful login commands:

- `fly login -t main -c http://${DUCC_HOSTNAME}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -k`
- `credhub login -s https://${DUCC_HOSTNAME}:9000 --client-name credhub_client --client-secret ${DUCC_CREDHUB_CLIENT_SECRET} --skip-tls-validation`
- `mc config host add docker http://${DUCC_HOSTNAME}:9080 minio ${DUCC_MINIO_SECRET} --api "s3v4"`

Concourse can be extended with features using the documentation and environmental variables in the `docker-compose.yml` file. For example the linked process can be followed to add LDAP authentication https://concourse-ci.org/ldap-auth.html

The Minio webpage is accessible on http://${DUCC_HOSTNAME}:9080 with username minio and the password from the `1-vars.sh` file.

# Managing Docker volume space
If using Concourse heavily with large resources, then the Docker volumes will consume quite a bit of space, so watch out for it filling the mount/disk. Depending on the pipelines run, it's good to have at least 100GB available. Volume size can be monitored with `docker system df` and if there are any unused volumes they are shown as reclaimable, so to reclaim run `docker system prune --volumes`. Concourse and Docker will grow and shrink the in use volumes automatically based on usage.

# Running Offline
It's possible to run offline, but an internet connected system running Docker is required to prepare the images.
- The prepare credhub script must be run on the internet connected machine.
- All the Docker images must be pulled onto an internet connected machine and then either pushed to a on-prem registry or manually moved to the Docker host.
     To manually move use `docker save` to generate a tar archive of each image. 
     Images should transported to the target Docker host and use `docker load` to add images to the local Docker cache.
- 'docker-compose.yml' should be updated to reflect the new image location and/or tags images. 

## Downloaded Docker Images
At runtime
- concourse/concourse
- cfidentity/uaa
- minio/minio
- postgres
- pcfseceng/credhub

# TODO
- Refactor to use latest Alpine based UAA image
- Add second compose file and scripts to enable generation of tls certs for all components
