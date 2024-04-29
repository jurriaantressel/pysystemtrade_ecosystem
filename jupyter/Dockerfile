FROM python:3.10.13 as builder

# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a jupyterlab container in the pysystemtrade_ecosystem"

ARG PROJECT_DIR=/opt/projects
RUN mkdir $PROJECT_DIR

ARG REPO_USER
ARG REPO_TOKEN

ARG PYSYS_REPO=pysystemtrade
RUN git clone -b develop https://$REPO_TOKEN:@github.com/$REPO_USER/$PYSYS_REPO.git $PROJECT_DIR/$PYSYS_REPO

FROM python:3.10.13 as final_stage

ENV TZ=${TZ:-America/Chicago}
RUN echo ">>>>>>>>>>>>>> TZ=$TZ"
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/timezone && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

RUN apt-get update
RUN yes | apt-get install vim

ARG PYSYS_REPO=pysystemtrade
ARG PROJECT_DIR=/opt/projects

RUN mkdir $PROJECT_DIR
RUN mkdir $PROJECT_DIR/$PYSYS_REPO
RUN mkdir /home/reports
RUN mkdir /home/logs


COPY --from=builder $PROJECT_DIR/$PYSYS_REPO/requirements.txt $PROJECT_DIR/requirements.txt

RUN pip3 install --upgrade pip
RUN pip3 install sqlalchemy==1.3.22
RUN pip3 install psycopg2-binary

WORKDIR $PROJECT_DIR
RUN pip3 install --requirement requirements.txt
RUN pip3 install jupyterlab

COPY --from=builder $PROJECT_DIR $PROJECT_DIR

WORKDIR $PROJECT_DIR/$PYSYS_REPO

RUN pip3 install -e .

COPY ./jupyter_server_config.py /usr/jupyter_server_config.py


ENTRYPOINT jupyter-lab --allow-root --no-browser --port=8888  --ip=0.0.0.0 --config=/usr/jupyter_server_config.py
