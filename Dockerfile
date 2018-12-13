# AIRFLOW VERSION: 1.10.1
# AUTHOR: zposloncec
# DESCRIPTION: Airflow docker image for RN
# BUILD: docker build --rm -t zposloncec/docker-airflow .
# SOURCE: https://github.com/zposloncec/docker-airflow

FROM centos:latest 
LABEL maintainer="zposloncec"

# AIRFLOW STUFF
ARG AIRFLOW_VERSION=1.10.1
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNICODE yes
ENV SLUGIFY_USES_TEXT_UNIDECODE yes

# DEFINE ENV
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8


RUN yum -y install epel-release 
RUN yum -y install python-pip 
RUN set -xe \
    && yum install -y \
       python-devel \
       python-setuptools \
       gcc \
       gcc-c++ \
       mysql-devel \
       libffi \
       libffi-devel \
       bzip2-devel \
       zlib-devel 
RUN pip install -U pip
RUN pip install -U setuptools wheel 
RUN pip install pytz 
RUN pip install pyOpenSSL 
RUN pip install ndg-httpsclient 
RUN pip install pyasn1 
RUN pip install apache-airflow[crypto,mysql${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} 
RUN pip install 'redis>=2.10.5,<3' 
RUN if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi 
RUN yum clean all
RUN rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow 

COPY script/upstart.sh /upstart.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/upstart.sh"]
CMD ["webserver"]
