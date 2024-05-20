FROM python:3.10.13



# Declare ARGs required for this stage
ARG SYSTEM_REPO_SOURCE_DIR
ARG SYSTEM_REPO_DIR
ARG SYSTEM_REPO_PRIVATE_DIR=$SYSTEM_REPO_DIR/private

COPY $SYSTEM_REPO_SOURCE_DIR $SYSTEM_REPO_DIR/

# Set environment variables for pysystemtrade
ENV PYSYS_CODE=$SYSTEM_REPO_DIR \
    PYSYS_PRIVATE_CONFIG_DIR=$SYSTEM_REPO_PRIVATE_DIR \
    SCRIPT_PATH=$SYSTEM_REPO_DIR/sysproduction/linux/scripts \
    PATH="$PATH:$SCRIPT_PATH"

RUN cat $SYSTEM_REPO_PRIVATE_DIR/private_config.yaml

WORKDIR $SYSTEM_REPO_DIR

# Install necessary build tools and libraries
RUN apt-get update && \
    apt-get install -y vim build-essential python3-dev libyaml-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel
RUN pip3 install --upgrade pip setuptools wheel


# Install Cython explicitly
RUN pip3 install cython

# Verify Cython installation
RUN python3 -m cython --version

# Install requirements with verbose logging
RUN pip3 install --requirement requirements.txt --verbose


