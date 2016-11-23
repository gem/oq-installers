FROM centos:centos7
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -y upgrade
RUN yum -y install sudo git unzip

RUN yum -y install python-pip
RUN pip install -U pip wheel

RUN useradd -u 1000 openquake && \
echo 'openquake ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir /opt/openquake && chown openquake.openquake /opt/openquake

USER openquake
ENV HOME /home/openquake
ENV PYTHONPATH $HOME/oq-engine:$HOME/oq-hazardlib

WORKDIR ${HOME}

RUN git clone https://github.com/gem/oq-hazardlib
RUN git clone https://github.com/gem/oq-engine
ADD runtests.sh ${HOME}

RUN mkdir /opt/openquake/lib && ln -rs /opt/openquake/lib /opt/openquake/lib64
RUN pip install --prefix /opt/openquake -r oq-engine/requirements-py27-linux64.txt

ENV PYTHONPATH $PYTHONPATH:/opt/openquake/lib
ENV PATH /opt/openquake/bin/:$PATH

WORKDIR ${HOME}
CMD ${HOME}/runtests.sh
