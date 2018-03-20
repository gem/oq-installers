# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
# vim: syntax=dockerfile
# name: f27-wine
#
# Copyright (C) 2017-2018 GEM Foundation
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

FROM fedora:27
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -y install wget && \
    dnf -y install python-markdown python-wheel wget git zip unzip && \
    dnf -y install wine

ARG uid=1000
RUN useradd -u $uid builder

USER builder
ENV HOME /home/builder
ENV PATH /opt/wine-stable/bin:$PATH
ENV WINEDEBUG -all 
WORKDIR $HOME

RUN wget -q http://cdn.ftp.openquake.org/windows/thirdparties/nsis-3.01-setup.exe && \
    wget -q http://cdn.ftp.openquake.org/windows/thirdparties/python-3.5.4.zip && \
    wget -q http://cdn.ftp.openquake.org/windows/thirdparties/get-pip.py

RUN wineboot && sleep 10

RUN wine nsis-3.01-setup.exe /S && sleep 10

CMD /bin/bash /io/docker/build.sh
