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

Debugging step to verify file exists
RUN ls /app
# RUN chmod +x /app/datadog-init

# Copy the rest of the application code
COPY . .

# Set environment variables
ENV FLASK_APP=application.py
ENV DD_SERVICE=cloudrun-python
ENV DD_ENV=cloudrun
ENV DD_VERSION=1

# Expose the application port
EXPOSE 5500

# Argument for commit SHA and set Datadog tags
ARG DD_GIT_COMMIT_SHA
ENV DD_TAGS="git.repository_url:github.com/jon94/cloudrunpythonbe,git.commit.sha:${DD_GIT_COMMIT_SHA}"

# Entry point and command to run the application
ENTRYPOINT ["/app/datadog-init"]
CMD ["/dd_tracer/python/bin/ddtrace-run", "python", "application.py"]

# Entry point and command to run the application
# CMD ["python", "application.py"]
