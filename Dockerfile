# Base image
FROM python:3.7

# Set the working directory
WORKDIR /flask_backend

# Copy and install dependencies first to leverage Docker cache
COPY requirements.txt /flask_backend/requirements.txt 
RUN pip3 install -r requirements.txt

# Copy Datadog serverless-init
COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init

# Install ddtrace to a specific target directory
RUN pip install --target /dd_tracer/python/ ddtrace

# Copy the rest of the application code
COPY . .

# Copy the JSON file into the /home/asm/ directory
COPY appsec-rules.json /home/asm/appsec-rules.json

RUN pwd

RUN ls /home/asm

# Set environment variables
ENV FLASK_APP=application.py
ENV DD_SERVICE=cloudrun-python
ENV DD_ENV=cloudrun
ENV DD_APPSEC_ENABLED=1
ENV DD_VERSION=1
ENV DD_REMOTE_CONFIGURATION_ENABLED=false
ENV DD_TRACE_ENABLED=true
ENV DD_APPSEC_RULES=/home/asm/appsec-rules.json
ENV DD_TRACE_DEBUG=true
ENV DD_LOG_LEVEL=debug

# Expose the application port
EXPOSE 5500

# Argument for commit SHA and set Datadog tags
ARG DD_GIT_COMMIT_SHA
ENV DD_TAGS="git.repository_url:github.com/jon94/cloudrunpythonbe,git.commit.sha:${DD_GIT_COMMIT_SHA}"

# Entry point and command to run the application
ENTRYPOINT ["/app/datadog-init"]
CMD ["/dd_tracer/python/bin/ddtrace-run", "python", "application.py"]
