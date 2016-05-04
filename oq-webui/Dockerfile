FROM centos:centos7
MAINTAINER Daniele Viganò <daniele@vigano.me>

RUN yum -y upgrade
RUN yum -y install epel-release git gcc
RUN curl -sLo /etc/yum.repos.d/gem-openquake-epel-7.repo https://copr.fedorainfracloud.org/coprs/gem/openquake/repo/epel-7/gem-openquake-epel-7.repo

RUN yum install -y python-oq-engine

USER openquake
ENV HOME /var/lib/openquake

WORKDIR /usr/lib/python2.7/site-packages/openquake/server

RUN python db/upgrade_manager.py ${HOME}/db.sqlite3

ADD runwebui.sh /usr/local/bin
EXPOSE 8000:8000
CMD /bin/bash /usr/local/bin/runwebui.sh
