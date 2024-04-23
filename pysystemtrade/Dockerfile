FROM python:3.10.13 as builder

RUN echo "Starting Docker build..."


# LABEL
LABEL maintainer="tobias@anti-gravity.as"
LABEL version="0.1"
LABEL description="This is custom Docker Image for creating a pysystemtrade container in the pysystemtrade_ecosystem"

ARG GIT_TOKEN
RUN echo "ARG GIT_TOKEN=$GIT_TOKEN"


RUN mkdir /opt/projects
RUN git clone -b develop https://$GIT_TOKEN:@github.com/makutaku/pysystemtrade.git /opt/projects/pysystemtrade


FROM python:3.10.13 as final_stage

ARG SCRIPT_PATH=$SCRIPT_PATH
RUN echo "ARG SCRIPT_PATH=$SCRIPT_PATH"

ENV SCRIPT_PATH=$SCRIPT_PATH
ENV PATH "$PATH:$SCRIPT_PATH"

RUN  ln -sf /usr/share/zoneinfo/Europe/London /etc/timezone && \
     ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt-get update
RUN yes | apt-get install vim

RUN mkdir /opt/projects
RUN mkdir /opt/projects/pysystemtrade


COPY --from=builder /opt/projects/pysystemtrade/requirements.txt /opt/projects/requirements.txt

RUN pip3 install --upgrade pip

WORKDIR /opt/projects

RUN pip3 install --requirement requirements.txt

COPY --from=builder /opt/projects /opt/projects

WORKDIR /opt/projects/pysystemtrade

RUN pip3 install -e .

RUN mkdir command_scripts
COPY ./command_scripts /opt/projects/pysystemtrade/command_scripts
COPY run_monitor_once.py /opt/projects/pysystemtrade/run_monitor_once.py

RUN mkdir /home/echos
RUN mkdir /home/csv_backup
RUN mkdir /home/reports
RUN mkdir /home/logs

RUN echo "Building complete."
