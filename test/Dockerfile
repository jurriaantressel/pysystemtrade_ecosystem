FROM python:3.10.13

## Set environment variable for timezone and configure timezone
#ENV TZ=${TZ:-America/Chicago}
#RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
#    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
#    mkdir -p /home/reports /home/logs && \
#    mkdir -p /home/echos /home/csv_backup
#
## Install vim, build-essential, and python3-dev, and upgrade pip in the same layer
#RUN apt-get update && \
#    apt-get install -y vim build-essential python3-dev && \
#    pip3 install --upgrade pip && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*



# Declare ARGs required for this stage
ARG SYSTEM_REPO_SOURCE_DIR
ARG SYSTEM_REPO_TARGET_DIR
ARG SYSTEM_REPO_PRIVATE_DIR=$SYSTEM_REPO_TARGET_DIR/private

COPY $SYSTEM_REPO_SOURCE_DIR $SYSTEM_REPO_TARGET_DIR/

# Set environment variables for pysystemtrade
ENV PYSYS_CODE=$SYSTEM_REPO_TARGET_DIR \
    PYSYS_PRIVATE_CONFIG_DIR=$SYSTEM_REPO_PRIVATE_DIR \
    SCRIPT_PATH=$SYSTEM_REPO_TARGET_DIR/sysproduction/linux/scripts \
    PATH="$PATH:$SCRIPT_PATH"

RUN cat $SYSTEM_REPO_PRIVATE_DIR/private_config.yaml

WORKDIR $SYSTEM_REPO_TARGET_DIR

RUN apt-get update && \
    apt-get install -y vim build-essential python3-dev && \
    pip3 install --upgrade pip setuptools wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install -r requirements.txt


## Install requirements and package
#RUN pip3 install --requirement requirements.txt && \
#    pip3 install -e .
#
## Copy and prepare command scripts
#COPY ./pysystemtrade/command_scripts ./command_scripts
#RUN find ./command_scripts -type f -name "*.bash" -exec chmod +x {} \;
#
#COPY ./pysystemtrade/run_monitor_once.py ./run_monitor_once.py
