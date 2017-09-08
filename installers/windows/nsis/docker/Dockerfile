# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
# vim: syntax=dockerfile
# name: f26-wine
#
# Copyright (C) 2017 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake. If not, see <http://www.gnu.org/licenses/>.

FROM fedora:26
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -q -y install python-markdown python-wheel wget git zip unzip && \
    wget -qO- https://repos.wine-staging.com/wine/fedora/26/winehq.repo > /etc/yum.repos.d/winehq.repo && \
    dnf -q -y install wine-stable64

ARG uid=1000
RUN useradd -u $uid builder

USER builder
ENV HOME /home/builder
ENV PATH /opt/wine-stable/bin:$PATH
ENV WINEDEBUG -all 
WORKDIR $HOME

RUN wget -q https://downloads.sourceforge.net/project/nsis/NSIS%203/3.01/nsis-3.01-setup.exe && \
    wget -q https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi && \
    pip -q wheel --disable-pip-version-check --no-deps wheel

RUN wineboot && sleep 10

RUN wine nsis-3.01-setup.exe /S && \
    wine msiexec /i python-2.7.13.amd64.msi TARGETDIR=C:\python27 && \
    wine pip -q install wheel && sleep 10

CMD /bin/bash /io/docker/build.sh
