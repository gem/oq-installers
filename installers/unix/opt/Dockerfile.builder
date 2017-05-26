# vi:syntax=dockerfile
FROM centos:6
MAINTAINER Daniele Viganò <daniele@openquake.org>

ARG uid=107

RUN yum -y upgrade && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install epel-release && \
    yum -y install autoconf bzip2-devel curl git gzip libtool makeself \
                   readline-devel spatialindex-devel sudo sqlite-devel tar \
                   which xz zip zlib-devel

RUN useradd -u $uid builder && \
echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builder

ENV HOME /home/builder
WORKDIR ${HOME}

CMD /bin/bash
