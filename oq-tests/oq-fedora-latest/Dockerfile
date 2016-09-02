FROM fedora:latest
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -y upgrade
RUN dnf -y install findutils git gcc redhat-rpm-config
RUN curl -sLo /etc/yum.repos.d/gem-openquake-fedora-23.repo https://copr.fedorainfracloud.org/coprs/gem/openquake/repo/fedora-23/gem-openquake-fedora-23.repo

RUN dnf install -y 'dnf-command(repoquery)'
RUN dnf repoquery --requires --resolve python-oq-engine | grep -v "Last metadata" | grep -v i686 | \
    grep -v python-oq | sed ':a;N;$!ba;s/\n/ /g' | xargs dnf -y install

RUN useradd -u 1000 openquake
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
