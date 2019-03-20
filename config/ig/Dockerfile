#ARG REPO=forgerock-docker-public.bintray.io/forgerock/ig
#ARG REPO=gcr.io/forgerock-io/ig
ARG REPO=gcr.io/forgerock-io/ig/1-docker-build
#ARG TAG=7.0.0-M143
ARG TAG=latest

FROM $REPO:$TAG

# Copy all config files into the docker image.
COPY --chown=forgerock ./ /config
