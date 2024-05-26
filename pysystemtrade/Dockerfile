FROM python:3.10.13

# Set environment variable for timezone and configure timezone
ENV TZ=${TZ:-America/Chicago}
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    mkdir -p /home/reports /home/logs && \
    mkdir -p /home/echos /home/csv_backup

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --upgrade pip

# Declare ARGs required for this stage
ARG SYSTEM_REPO_SOURCE_DIR
ARG SYSTEM_REPO_DIR
ARG SYSTEM_REPO_PRIVATE_DIR=$SYSTEM_REPO_DIR/private

COPY $SYSTEM_REPO_SOURCE_DIR/app $SYSTEM_REPO_DIR/

# Set environment variables for pysystemtrade
ENV PYSYS_CODE=$SYSTEM_REPO_DIR \
    PYSYS_PRIVATE_CONFIG_DIR=$SYSTEM_REPO_PRIVATE_DIR \
    SCRIPT_PATH=$SYSTEM_REPO_DIR/sysproduction/linux/scripts \
    PATH="$PATH:$SCRIPT_PATH"

# RUN cat $SYSTEM_REPO_PRIVATE_DIR/private_config.yaml

WORKDIR $SYSTEM_REPO_DIR

# Install requirements and package
RUN cat requirements.txt && \
    pip3 install --requirement requirements.txt && \
    pip3 install -e .


COPY ./pysystemtrade/command_scripts ./command_scripts
RUN find ./command_scripts -type f -name "*.bash" -exec chmod +x {} \;

COPY ./pysystemtrade/run_monitor_once.py ./run_monitor_once.py
