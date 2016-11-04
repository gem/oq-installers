FROM ubuntu:xenial
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y sudo software-properties-common python-setuptools git unzip
RUN add-apt-repository -y ppa:openquake-automatic-team/latest-master

RUN apt-get update
RUN apt-cache depends python-oq-hazardlib | awk '/Depends:/{print$2}' | grep -vE 'python-oq.*|debconf.*' | xargs apt-get install -y
RUN apt-cache depends python-oq-engine | awk '/Depends:/{print$2}' | grep -vE 'python-oq.*|debconf.*' | xargs apt-get install -y

RUN apt-get install -y python-pip
RUN pip install -U pip wheel


RUN adduser --system openquake && \
echo 'openquake ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER openquake
ENV HOME /home/openquake
ENV PYTHONPATH $HOME/oq-engine:$HOME/oq-hazardlib

WORKDIR ${HOME}

RUN git clone https://github.com/gem/oq-hazardlib
RUN git clone https://github.com/gem/oq-engine
ADD runtests.sh ${HOME}

RUN mkdir lib
RUN pip install --target $HOME/lib -r oq-engine/requirements-py27-linux64.txt

ENV PYTHONPATH $PYTHONPATH:$HOME/lib

WORKDIR ${HOME}
CMD ${HOME}/runtests.sh
