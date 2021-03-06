ARG DOCKER_BASE_IMAGE
FROM $DOCKER_BASE_IMAGE

# root user is required for the coming operations
USER root

# create servers
WORKDIR /pgadmin4/
COPY ./servers.json ./servers.json

ARG APP_PREFIX
ARG POSTGRES_HOST_NAME
ARG POSTGRES_PORT
ARG POSTGRES_DEFAULT_DATABASE_NAME
ARG POSTGRES_SUPER_USER_ROLE_NAME
RUN sed -i -r "s/%%APP_PREFIX%%/${APP_PREFIX}/g" servers.json && \
  sed -i -r "s/%%POSTGRES_HOST_NAME%%/${POSTGRES_HOST_NAME}/g" servers.json && \
  sed -i -r "s/%%POSTGRES_PORT%%/${POSTGRES_PORT}/g" servers.json && \
  sed -i -r "s/%%POSTGRES_DEFAULT_DATABASE_NAME%%/${POSTGRES_DEFAULT_DATABASE_NAME}/g" servers.json && \
  sed -i -r "s/%%POSTGRES_SUPER_USER_ROLE_NAME%%/${POSTGRES_SUPER_USER_ROLE_NAME}/g" servers.json

# create passwords
WORKDIR /var/lib/pgadmin/storage/
ARG PGADMIN_USER_DIR
RUN mkdir -m 700 ./${PGADMIN_USER_DIR} && \
  echo "${POSTGRES_HOST_NAME}:${POSTGRES_HOST_NAME}:${POSTGRES_DEFAULT_DATABASE_NAME}:${POSTGRES_SUPER_USER_ROLE_NAME}:${POSTGRES_SUPER_USER_SECRET}" > ./${PGADMIN_USER_DIR}/pgpassfile && \ 
  chmod 600 ./${PGADMIN_USER_DIR}/pgpassfile

HEALTHCHECK --interval=5s --timeout=3s CMD wget --no-verbose --tries=1 --spider http://localhost/login || exit 1
