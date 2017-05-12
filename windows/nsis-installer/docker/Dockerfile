# vi:syntax=dockerfile
FROM fedora:25
MAINTAINER Daniele Viganò <daniele@openquake.org>

ARG uid=1000

RUN dnf -y install wine python-markdown wget git unzip

RUN useradd -u 1000 builder

USER builder
ENV HOME /home/builder
ENV WINEDEBUG -all 
WORKDIR $HOME

RUN wget -q https://downloads.sourceforge.net/project/nsis/NSIS%203/3.01/nsis-3.01-setup.exe && \
    wget -q https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi
    
RUN wine nsis-3.01-setup.exe /S && \
    wine msiexec /i python-2.7.13.amd64.msi TARGETDIR=C:\python27 && \
    wine pip install wheel

CMD /bin/bash /io/docker/build.sh
