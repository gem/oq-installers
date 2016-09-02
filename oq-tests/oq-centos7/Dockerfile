FROM centos:centos7
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -y upgrade
RUN yum -y install epel-release sudo git gcc
RUN curl -sLo /etc/yum.repos.d/gem-openquake-epel-7.repo https://copr.fedorainfracloud.org/coprs/gem/openquake/repo/epel-7/gem-openquake-epel-7.repo

RUN yum deplist python-oq-engine | grep provider | \
awk '{print $2}' | sort | uniq | grep -v python-oq | \
sed ':a;N;$!ba;s/\n/ /g' | xargs yum -y install

RUN useradd -u 1000 openquake && \
echo 'openquake ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER openquake
ENV HOME /home/openquake
ENV PYTHONPATH $HOME/oq-engine:$HOME/oq-hazardlib

WORKDIR ${HOME}

RUN git clone https://github.com/gem/oq-hazardlib
RUN git clone https://github.com/gem/oq-engine
RUN cd oq-hazardlib ; \
    python setup.py build_ext ; \
    cd openquake/hazardlib/geo ; \
    ln -s ../../../build/lib.*/openquake/hazardlib/geo/*.so .
ADD runtests.sh ${HOME}

CMD /bin/bash runtests.sh
