FROM python:3.10.13 as builder

# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a pysystemtrade container in the pysystemtrade_ecosystem"

ARG PROJECT_DIR=/opt/projects
RUN mkdir $PROJECT_DIR

ARG REPO_USER
ARG REPO_TOKEN

ARG PYSYS_REPO=pysystemtrade
RUN git clone -b develop https://$REPO_TOKEN:@github.com/$REPO_USER/$PYSYS_REPO.git $PROJECT_DIR/$PYSYS_REPO

# Begin private config preparation
ARG PRIVATE_REPO=private_pysystemtrade
RUN git clone -b master https://$REPO_TOKEN:@github.com/$REPO_USER/$PRIVATE_REPO.git $PROJECT_DIR/$PRIVATE_REPO
# Replace tokens in the YAML file using envsubst
# Install gettext using apt
RUN apt-get update && \
    apt-get install -y gettext
ARG IB_IP_ADDRESS
ENV IB_IP_ADDRESS=$IB_IP_ADDRESS
ARG IB_PORT
ENV IB_PORT=$IB_PORT
ARG IB_OFFSET
ENV IB_OFFSET=$IB_OFFSET
ARG IB_ACCOUNT
ENV IB_ACCOUNT=$IB_ACCOUNT
ARG PARQUET_STORE
ENV PARQUET_STORE=${PARQUET_STORE:-/data/parquet_store}
ARG MONGO_HOST
ENV MONGO_HOST=$MONGO_HOST
ARG MONGO_DB
ENV MONGO_DB=$MONGO_DB
ARG EMAIL_ADDRESS
ENV EMAIL_ADDRESS=$EMAIL_ADDRESS
ARG EMAIL_PWD
ENV EMAIL_PWD=$EMAIL_PWD
ARG EMAIL_SERVER
ENV EMAIL_SERVER=$EMAIL_SERVER
ARG EMAIL_TO
ENV EMAIL_TO=$EMAIL_TO
ARG EMAIL_PORT
ENV EMAIL_PORT=$EMAIL_PORT
RUN cd $PROJECT_DIR/$PRIVATE_REPO/private/ && envsubst < private_config.yaml.template > private_config.yaml
RUN cat $PROJECT_DIR/$PRIVATE_REPO/private/private_config.yaml
# End private config preparation


FROM python:3.10.13 as final_stage

ENV TZ=${TZ:-America/Chicago}
RUN echo ">>>>>>>>>>>>>> TZ=$TZ"
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

RUN apt-get update
RUN yes | apt-get install vim

ARG PYSYS_REPO=pysystemtrade
ARG PRIVATE_REPO=private_pysystemtrade
ARG PROJECT_DIR=/opt/projects

RUN mkdir $PROJECT_DIR
RUN mkdir $PROJECT_DIR/$PYSYS_REPO
RUN mkdir /home/reports
RUN mkdir /home/logs

RUN mkdir /home/echos
RUN mkdir /home/csv_backup

ARG PYSYS_PRIVATE_CONFIG_DIR
ENV PYSYS_PRIVATE_CONFIG_DIR=${PYSYS_PRIVATE_CONFIG_DIR:-$PROJECT_DIR/$PRIVATE_REPO/private}
RUN echo ">>>>>>>>>>>>>> PYSYS_PRIVATE_CONFIG_DIR=$PYSYS_PRIVATE_CONFIG_DIR"

ARG PYSYS_CODE
ENV PYSYS_CODE=${PYSYS_CODE:-$PROJECT_DIR/$PYSYS_REPO}
RUN echo ">>>>>>>>>>>>>> PYSYS_CODE=$PYSYS_CODE"

ARG SCRIPT_PATH
ENV SCRIPT_PATH=${SCRIPT_PATH:-$PROJECT_DIR/$PYSYS_REPO/sysproduction/linux/scripts}
RUN echo ">>>>>>>>>>>>>> SCRIPT_PATH=$SCRIPT_PATH"
ENV PATH "$PATH:$SCRIPT_PATH"



COPY --from=builder $PROJECT_DIR/$PYSYS_REPO/requirements.txt $PROJECT_DIR/requirements.txt

RUN pip3 install --upgrade pip

WORKDIR $PROJECT_DIR
RUN pip3 install --requirement requirements.txt

COPY --from=builder $PROJECT_DIR $PROJECT_DIR

WORKDIR $PROJECT_DIR/$PYSYS_REPO

RUN pip3 install -e .

RUN mkdir command_scripts
COPY ./command_scripts $PROJECT_DIR/$PYSYS_REPO/command_scripts
COPY run_monitor_once.py $PROJECT_DIR/$PYSYS_REPO/run_monitor_once.py

