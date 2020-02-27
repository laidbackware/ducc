export DUCC_HOSTNAME=localhost # Can be IP or hostname. Needs to be changed if access externally.
export DUCC_CONCOURSE_ADMIN_PASSWORD=test
export DUCC_ENCRYPTION_PASSWORD=changeme
export DUCC_POSTGRES_PASSWORD=changeme
export DUCC_CREDHUB_CLIENT_SECRET=changeme
export DUCC_TRUST_STORE_PASSWORD=changeit # Cannot be changed currently
export DUCC_MINIO_SECRET=minio123
export DUCC_MINIO_PATH=$(mkdir -p /tmp/minio && echo /tmp/minio)  # This should be updated to a persistent location!