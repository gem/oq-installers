# vi:syntax=dockerfile
FROM fedora:25
MAINTAINER Daniele Viganò <daniele@openquake.org>

ARG uid=1000

RUN dnf -y install wine python-markdown python-wheel wget git zip unzip

RUN useradd -u 1000 builder

USER builder
ENV HOME /home/builder
ENV WINEDEBUG -all 
WORKDIR $HOME

RUN wget -q https://downloads.sourceforge.net/project/nsis/NSIS%203/3.01/nsis-3.01-setup.exe && \
    wget -q https://www.python.org/ftp/python/3.5.3/python-3.5.3-embed-amd64.zip && \
    wget -q https://bootstrap.pypa.io/get-pip.py
    
RUN wineboot && sleep 10

RUN wine nsis-3.01-setup.exe /S && sleep 10

CMD /bin/bash /io/docker/build.sh
