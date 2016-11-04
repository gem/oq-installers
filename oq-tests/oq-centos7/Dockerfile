FROM centos:centos7
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -y upgrade
RUN yum -y install epel-release sudo git gcc unzip
RUN curl -sLo /etc/yum.repos.d/gem-openquake-epel-7.repo https://copr.fedorainfracloud.org/coprs/gem/openquake/repo/epel-7/gem-openquake-epel-7.repo

RUN yum deplist python-oq-engine | grep provider | \
awk '{print $2}' | sort | uniq | grep -v python-oq | \
sed ':a;N;$!ba;s/\n/ /g' | xargs yum -y install

RUN yum -y install python-pip
RUN pip install -U pip wheel

RUN useradd -u 1000 openquake && \
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
