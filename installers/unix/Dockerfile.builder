# vi:syntax=dockerfile
# name:centos6-builder
FROM centos:6
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -y upgrade && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install centos-release-scl epel-release && \
    yum -y install autoconf bzip2-devel curl git gzip libtool makeself \
                   readline-devel python27 rh-python35 spatialindex-devel \
                   sudo sqlite-devel tar which xz zip zlib-devel

ARG uid=107

RUN useradd -u $uid builder && \
echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builder

ENV HOME /home/builder

WORKDIR ${HOME}

CMD /bin/bash
