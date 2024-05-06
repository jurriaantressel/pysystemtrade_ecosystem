FROM python:3.10.13 as builder

# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a pysystemtrade container in the pysystemtrade_ecosystem"

# Update package lists and install required tools
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && rm -rf /var/lib/apt/lists/*

# Download HashiCorp GPG key and add repository
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com focal main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y vault \
    && apt-get install -y gnupg jq \
    && apt-get install -y gettext \
    && rm -rf /var/lib/apt/lists/*


# Set build arguments

ARG PROJECT_DIR=/opt/projects
RUN mkdir $PROJECT_DIR


ARG IB_IP_ADDRESS
ENV IB_IP_ADDRESS=$IB_IP_ADDRESS
ARG IB_PORT
ENV IB_PORT=$IB_PORT
ARG IB_OFFSET
ENV IB_OFFSET=$IB_OFFSET
ARG PARQUET_STORE
ENV PARQUET_STORE=${PARQUET_STORE:-/data/parquet_store}
RUN echo "PARQUET_STORE=$PARQUET_STORE"

ARG MONGO_HOST
ENV MONGO_HOST=$MONGO_HOST
ARG MONGO_DB
ENV MONGO_DB=$MONGO_DB
ARG EMAIL_SERVER
ENV EMAIL_SERVER=$EMAIL_SERVER
ARG EMAIL_TO
ENV EMAIL_TO=$EMAIL_TO
ARG EMAIL_PORT
ENV EMAIL_PORT=$EMAIL_PORT

ARG HELP_SCRIPTS_PATH=/usr/local/bin

# Copy the scripts into the image
COPY fetch_secret_as_vars.sh $HELP_SCRIPTS_PATH/fetch_secret_as_vars.sh
COPY append_script.sh $HELP_SCRIPTS_PATH/append_script.sh

ARG APPEND_SCRIPT="${HELP_SCRIPTS_PATH}/append_script.sh"
ARG FETCH_SECRET_AS_VARS_SCRIPT="${HELP_SCRIPTS_PATH}/fetch_secret_as_vars.sh"

# Make the script executable
RUN chmod +x $FETCH_SECRET_AS_VARS_SCRIPT && \
    chmod +x $APPEND_SCRIPT

ARG VAULT_TOKEN=$VAULT_TOKEN
ARG VAULT_ADDR=$VAULT_ADDR
RUN vault login $VAULT_TOKEN

ARG ENV_FILE="/tmp/env_vars.sh"

ARG SYSTEM_REPO_PREFIX='SYSTEM_REPO_'
ARG SYSTEM_REPO_ACCESS=$SYSTEM_REPO_ACCESS
RUN $APPEND_SCRIPT $ENV_FILE "$($FETCH_SECRET_AS_VARS_SCRIPT $SYSTEM_REPO_ACCESS export' '$SYSTEM_REPO_PREFIX)"

ARG CONFIG_REPO_PREFIX='CONFIG_REPO_'
ARG CONFIG_REPO_ACCESS=$CONFIG_REPO_ACCESS
RUN $APPEND_SCRIPT $ENV_FILE "$($FETCH_SECRET_AS_VARS_SCRIPT $CONFIG_REPO_ACCESS export' '$CONFIG_REPO_PREFIX)"

ARG EMAIL_ACCOUNT_PREFIX='EMAIL_'
ARG EMAIL_ACCOUNT_ACCESS=$EMAIL_ACCOUNT_ACCESS
RUN $APPEND_SCRIPT $ENV_FILE "$($FETCH_SECRET_AS_VARS_SCRIPT $EMAIL_ACCOUNT_ACCESS export' '$EMAIL_ACCOUNT_PREFIX)"

ARG IB_PREFIX="IBKR_"
ARG IB_ACCOUNT_ACCESS=$IB_ACCOUNT_ACCESS
RUN $APPEND_SCRIPT $ENV_FILE "$($FETCH_SECRET_AS_VARS_SCRIPT $IB_ACCOUNT_ACCESS export' '$IB_PREFIX)"

# TODO: remove when done debugging
RUN cat $ENV_FILE

ARG SYSTEM_REPO_NAME=$SYSTEM_REPO_NAME
ARG CONFIG_REPO_NAME=$CONFIG_REPO_NAME
RUN . $ENV_FILE && \
    git clone -b develop https://$SYSTEM_REPO_ACCESS_TOKEN:@github.com/$SYSTEM_REPO_OWNER/$SYSTEM_REPO_NAME.git $PROJECT_DIR/$SYSTEM_REPO_NAME && \
    git clone -b master https://$CONFIG_REPO_ACCESS_TOKEN:@github.com/$CONFIG_REPO_OWNER/$CONFIG_REPO_NAME.git $PROJECT_DIR/$CONFIG_REPO_NAME

# Replace tokens in the YAML file using envsubst
ENV CONFIG_REPO_PRIVATE_DIR=$PROJECT_DIR/$CONFIG_REPO_NAME/private
RUN . $ENV_FILE && cd $CONFIG_REPO_PRIVATE_DIR && envsubst < private_config.yaml.template > private_config.yaml
RUN . $ENV_FILE && cat $CONFIG_REPO_PRIVATE_DIR/private_config.yaml

# Load the .env file and set environment variables
#RUN export $(cat /run/abc_broker_credentials.env | xargs)
# Use envsubst to replace placeholders in the template file
#RUN envsubst "$(cat /run/abc_broker_credentials.env | xargs)" < /app/template_file > /app/updated_template_file


FROM python:3.10.13 as final_stage

ENV TZ=${TZ:-America/Chicago}

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
  apt-get update && \
  yes | apt-get install vim && \
  pip3 install --upgrade pip && \
  mkdir /home/reports && \
  mkdir /home/logs && \
  mkdir /home/echos && \
  mkdir /home/csv_backup

# TODO: is this needed?
#ARG ENV_FILE="/tmp/env_vars.sh"
#COPY --from=builder $ENV_FILE $ENV_FILE

ARG SYSTEM_REPO_NAME=$SYSTEM_REPO_NAME
ARG CONFIG_REPO_NAME=$CONFIG_REPO_NAME

ARG PROJECT_DIR=/opt/projects

ENV PYSYS_CODE=$PROJECT_DIR/$SYSTEM_REPO_NAME
RUN echo "PYSYS_CODE=$PYSYS_CODE"

ENV PYSYS_PRIVATE_CONFIG_DIR=$PROJECT_DIR/$CONFIG_REPO_NAME/private
RUN echo "PYSYS_PRIVATE_CONFIG_DIR=$PYSYS_PRIVATE_CONFIG_DIR"

ENV SCRIPT_PATH=$PROJECT_DIR/$SYSTEM_REPO_NAME/sysproduction/linux/scripts
RUN echo "SCRIPT_PATH=$SCRIPT_PATH"
ENV PATH "$PATH:$SCRIPT_PATH"

RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

COPY --from=builder $PROJECT_DIR/$SYSTEM_REPO_NAME/requirements.txt $PROJECT_DIR/requirements.txt
RUN pip3 install --requirement requirements.txt

COPY --from=builder $PROJECT_DIR $PROJECT_DIR
WORKDIR $PROJECT_DIR/$SYSTEM_REPO_NAME

RUN pip3 install -e .

RUN mkdir command_scripts
COPY ./command_scripts $PROJECT_DIR/$SYSTEM_REPO_NAME/command_scripts
# Change the permissions of all bash scripts to make them executable
RUN find ./command_scripts -type f -name "*.bash" -exec chmod +x {} \;

COPY run_monitor_once.py $PROJECT_DIR/$SYSTEM_REPO_NAME/run_monitor_once.py

