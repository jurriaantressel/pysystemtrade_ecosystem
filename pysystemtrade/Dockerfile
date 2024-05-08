FROM python:3.10.13 as builder

# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a pysystemtrade container in the pysystemtrade_ecosystem"

# Update package lists and install required tools
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && apt-get install -y gnupg jq \
    && apt-get install -y gettext \
    && rm -rf /var/lib/apt/lists/*


# Set build arguments

ARG PROJECT_DIR=/opt/projects
RUN mkdir $PROJECT_DIR

ARG SYSTEM_REPO_NAME=$SYSTEM_REPO_NAME
ARG SYSTEM_REPO_OWNER=$SYSTEM_REPO_OWNER
ARG SYSTEM_REPO_ACCESS_TOKEN=$SYSTEM_REPO_ACCESS_TOKEN

ARG CONFIG_REPO_NAME=${CONFIG_REPO_NAME}
ARG CONFIG_REPO_OWNER=${CONFIG_REPO_OWNER}
ARG CONFIG_REPO_ACCESS_TOKEN=${CONFIG_REPO_ACCESS_TOKEN}

RUN git clone -b develop https://$SYSTEM_REPO_ACCESS_TOKEN:@github.com/$SYSTEM_REPO_OWNER/$SYSTEM_REPO_NAME.git $PROJECT_DIR/$SYSTEM_REPO_NAME && \
    git clone -b master https://$CONFIG_REPO_ACCESS_TOKEN:@github.com/$CONFIG_REPO_OWNER/$CONFIG_REPO_NAME.git $PROJECT_DIR/$CONFIG_REPO_NAME


ARG IB_GATEWAY_IPV4_ADDRESS
ENV IB_GATEWAY_IPV4_ADDRESS=$IB_GATEWAY_IPV4_ADDRESS
ARG IB_GATEWAY_PORT
ENV IB_GATEWAY_PORT=$IB_GATEWAY_PORT
ARG IB_GATEWAY_OFFSET
ENV IB_GATEWAY_OFFSET=$IB_GATEWAY_OFFSET
ARG IBKR_ACCOUNT
ENV IBKR_ACCOUNT=$IBKR_ACCOUNT

ARG PARQUET_STORE
ENV PARQUET_STORE=${PARQUET_STORE:-/data/parquet_store}
RUN echo "PARQUET_STORE=$PARQUET_STORE"

ARG MONGO_DB_HOST
ENV MONGO_DB_HOST=$MONGO_DB_HOST
ARG MONGO_DB_DATABASE
ENV MONGO_DB_DATABASE=$MONGO_DB_DATABASE
ARG MONGO_DB_PORT
ENV MONGO_DB_PORT=$MONGO_DB_PORT

ARG EMAIL_USER_ID
ENV EMAIL_USER_ID=$EMAIL_USER_ID
ARG EMAIL_PASSWORD
ENV EMAIL_PASSWORD=$EMAIL_PASSWORD
ARG EMAIL_SERVER
ENV EMAIL_SERVER=$EMAIL_SERVER
ARG EMAIL_TO
ENV EMAIL_TO=$EMAIL_TO
ARG EMAIL_PORT
ENV EMAIL_PORT=$EMAIL_PORT

# Replace tokens in the YAML file using envsubst
ENV CONFIG_REPO_PRIVATE_DIR=$PROJECT_DIR/$CONFIG_REPO_NAME/private
RUN cd $CONFIG_REPO_PRIVATE_DIR && envsubst < private_config.yaml.template > private_config.yaml
RUN cat $CONFIG_REPO_PRIVATE_DIR/private_config.yaml


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

