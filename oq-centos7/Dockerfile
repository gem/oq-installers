FROM centos:centos7
MAINTAINER Daniele Viganò <daniele@vigano.me>

ADD gem-openquake-epel-7.repo /etc/yum.repos.d/
RUN yum -y install epel-release
RUN yum -y upgrade

RUN useradd -u 1000 openquake

RUN yum -y install python-oq-engine

USER openquake
ENV HOME /home/openquake

CMD cd /usr/lib64/python2.7/site-packages/openquake/hazardlib/; /usr/bin/nosetests -v; cd /usr/lib/python2.7/site-packages/openquake/risklib/; /usr/bin/nosetests -v
