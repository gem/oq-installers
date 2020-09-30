# vi:syntax=dockerfile
# name:centos6-builder
FROM centos:6
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -q -y upgrade && \
    yum -q -y groupinstall 'Development Tools' && \
    yum -q -y install centos-release-scl epel-release && \
    yum -q -y install autoconf bzip2-devel curl git gzip libtool makeself \
                   readline-devel spatialindex-devel sudo sqlite-devel tar \
                   which xz zip zlib-devel

ARG uid=998

RUN useradd -u $uid builder && \
echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builder

ENV HOME /home/builder

WORKDIR ${HOME}

CMD /bin/bash
