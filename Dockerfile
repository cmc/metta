FROM ubuntu:16.04
MAINTAINER chris@cmcsec.com

USER root
RUN apt-get update && \
    apt-get -y upgrade 
RUN apt-get install python-dev python-pip python-virtualenv \
    libpcap-dev openssl sudo build-essential redis-server git \
    screen python-yaml -y
# this is a fix per https://github.com/pypa/pip/issues/5240
RUN pip install --upgrade pip==9.0.3
# end fix
RUN pip install --user pipenv
RUN git clone https://github.com/uber-common/metta.git
RUN virtualenv metta
RUN . metta/bin/activate
RUN pip install -r metta/requirements.txt
EXPOSE 6379/tcp
# todo: make this an upstart/init script (celery start)
RUN screen -dmS celery bash metta/start_vagrant_celery.sh
COPY ./config.ini metta/
# demo: run specific sim
RUN cd metta && python run_simulation_yaml.py -f MITRE/Adversarial_Simulation/ontarget_recon.yml
