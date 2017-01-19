# vi:syntax=dockerfile
FROM centos:6
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN yum -y upgrade && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install epel-release && \
    yum -y install autoconf bzip2-devel curl git gzip libtool makeself \
                   readline-devel spatialindex-devel sqlite-devel tar which xz zlib-devel

CMD /bin/bash
