#ARG REPO=forgerock-docker-public.bintray.io/forgerock/ig
ARG REPO=gcr.io/forgerock-io/ig
#ARG TAG=7.0.0-M143
ARG TAG=7.0.0

FROM $REPO:$TAG

# Copy all config files into the docker image.
COPY --chown=forgerock ./ /config
