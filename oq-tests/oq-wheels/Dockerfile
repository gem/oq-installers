FROM ubuntu:precise
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget gcc git python-dev
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN wget https://raw.githubusercontent.com/gem/oq-engine/master/requirements-py27-linux64.txt
RUN pip install -r requirements-py27-linux64.txt

RUN adduser --system openquake
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

CMD /bin/bash
