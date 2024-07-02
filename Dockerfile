#!/bin/sh

#Instructions to run the docker image

FROM python:3.7

WORKDIR /flask_backend

#install dependencies first so they can be cached

COPY requirements.txt /flask_backend/requirements.txt 
#package*.json./
RUN pip3 install -r requirements.txt
COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init
RUN pip install --target /dd_tracer/python/ ddtrace

COPY . .
#copies everything in the root directory to the container
#but lets say we want to ignore the env file -> .dockerignore

ENV FLASK_APP=application.py
ENV PORT=5500
ENV DD_SERVICE=cloudrun-python
ENV DD_ENV=cloudrun
ENV DD_VERSION=1

EXPOSE 5500

ARG DD_GIT_COMMIT_SHA
ENV DD_TAGS="git.repository_url:github.com/jon94/cloudrunpythonbe,git.commit.sha:${DD_GIT_COMMIT_SHA}" 


ENTRYPOINT ["/app/datadog-init"]
CMD ["/dd_tracer/python/bin/ddtrace-run", "python", "application.py"]