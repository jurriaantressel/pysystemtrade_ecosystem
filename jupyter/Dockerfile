FROM python:3.10.13 as builder

# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a jupyterlab container in the pysystemtrade_ecosystem"

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

FROM python:3.10.13 as final_stage

ENV TZ=${TZ:-America/Chicago}

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    mkdir /home/reports && \
    mkdir /home/logs && \
    apt-get update && \
    yes | apt-get install vim && \
    pip3 install --upgrade pip && \
    pip3 install sqlalchemy==1.3.22 && \
    pip3 install psycopg2-binary


ARG SYSTEM_REPO_NAME=$SYSTEM_REPO_NAME
ARG CONFIG_REPO_NAME=$CONFIG_REPO_NAME

ARG PROJECT_DIR=/opt/projects



RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

COPY --from=builder $PROJECT_DIR/$SYSTEM_REPO_NAME/requirements.txt $PROJECT_DIR/requirements.txt
RUN pip3 install --requirement requirements.txt && \
    pip3 install jupyterlab

COPY --from=builder $PROJECT_DIR $PROJECT_DIR
WORKDIR $PROJECT_DIR/$SYSTEM_REPO_NAME

RUN pip3 install -e .

COPY ./jupyter_server_config.py /usr/jupyter_server_config.py

ENTRYPOINT jupyter-lab --allow-root --no-browser --port=8888  --ip=0.0.0.0 --config=/usr/jupyter_server_config.py
