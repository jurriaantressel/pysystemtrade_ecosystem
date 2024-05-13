# Base Python image
FROM python:3.10.13 as builder

LABEL maintainer="tobias@anti-gravity.as" \
      version="0.1" \
      description="This is custom Docker Image for creating a pysystemtrade container in the pysystemtrade_ecosystem"

ARG PROJECT_DIR=/opt/projects
RUN mkdir -p $PROJECT_DIR

ARG SYSTEM_REPO_NAME
ARG SYSTEM_REPO_OWNER
ARG SYSTEM_REPO_ACCESS_TOKEN
RUN git clone -b develop https://$SYSTEM_REPO_ACCESS_TOKEN:@github.com/$SYSTEM_REPO_OWNER/$SYSTEM_REPO_NAME.git $PROJECT_DIR/$SYSTEM_REPO_NAME

ARG SYSTEM_REPO_PRIVATE_DIR=$PROJECT_DIR/$SYSTEM_REPO_NAME/private
COPY build/$SYSTEM_REPO_NAME/private_config.yaml $SYSTEM_REPO_PRIVATE_DIR/private_config.yaml
RUN cat $SYSTEM_REPO_PRIVATE_DIR/private_config.yaml

# Final stage
FROM python:3.10.13 as final_stage

# Set environment variable for timezone and configure timezone
ENV TZ=${TZ:-America/Chicago}
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    mkdir -p /home/reports /home/logs && \
    mkdir -p /home/echos /home/csv_backup

# Install vim and upgrade pip in the same layer
RUN apt-get update && \
    apt-get install -y vim && \
    pip3 install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Declare ARGs required for this stage
ARG PROJECT_DIR=/opt/projects
ARG SYSTEM_REPO_NAME

# Copy project directory from builder stage
COPY --from=builder $PROJECT_DIR $PROJECT_DIR

# Set environment variables for pysystemtrade
ENV PYSYS_CODE=$PROJECT_DIR/$SYSTEM_REPO_NAME \
    PYSYS_PRIVATE_CONFIG_DIR=$PROJECT_DIR/$SYSTEM_REPO_NAME/private \
    SCRIPT_PATH=$PROJECT_DIR/$SYSTEM_REPO_NAME/sysproduction/linux/scripts \
    PATH="$PATH:$SCRIPT_PATH"

WORKDIR $PROJECT_DIR/$SYSTEM_REPO_NAME

# Install requirements and package
RUN pip3 install --requirement requirements.txt && \
    pip3 install -e .

# Copy and prepare command scripts
COPY ./pysystemtrade/command_scripts ./command_scripts
RUN find ./command_scripts -type f -name "*.bash" -exec chmod +x {} \;

COPY ./pysystemtrade/run_monitor_once.py ./run_monitor_once.py
