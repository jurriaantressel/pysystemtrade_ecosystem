FROM python:3.10.13

# Set environment variable for timezone and configure timezone
ENV TZ=${TZ:-America/Chicago}
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    mkdir -p /home/reports /home/logs

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --upgrade pip && \
    pip3 install sqlalchemy==1.3.22 && \
    pip3 install psycopg2-binary

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

# Install requirements and package
RUN pip3 install jupyterlab && \
    cat requirements.txt && \
    pip3 install --requirement requirements.txt && \
    pip3 install -e .

COPY ./jupyter/jupyter_server_config.py /usr/jupyter_server_config.py

ENTRYPOINT jupyter-lab --allow-root --no-browser --port=8888  --ip=0.0.0.0 --config=/usr/jupyter_server_config.py
