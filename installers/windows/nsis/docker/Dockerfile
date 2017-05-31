# vi:syntax=dockerfile
FROM fedora:25
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -y install python-markdown python-wheel wget git zip unzip && \
    wget -qO- https://repos.wine-staging.com/wine/fedora/25/winehq.repo > /etc/yum.repos.d/winehq.repo && \
    dnf -y install wine-stable64

ARG uid=1000
RUN useradd -u $uid builder

USER builder
ENV HOME /home/builder
ENV PATH /opt/wine-stable/bin:$PATH
ENV WINEDEBUG -all 
WORKDIR $HOME

RUN wget -q https://downloads.sourceforge.net/project/nsis/NSIS%203/3.01/nsis-3.01-setup.exe && \
    wget -q https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi && \
    pip wheel --disable-pip-version-check --no-deps wheel

RUN wineboot && sleep 10

RUN wine nsis-3.01-setup.exe /S && \
    wine msiexec /i python-2.7.13.amd64.msi TARGETDIR=C:\python27 && \
    wine pip install wheel && sleep 10

CMD /bin/bash /io/docker/build.sh
