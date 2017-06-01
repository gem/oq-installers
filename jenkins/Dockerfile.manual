# vi:syntax=dockerfile
FROM ubuntu:xenial
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN apt update && \
    apt upgrade -y

RUN apt install -y texlive-full \
                   poppler-utils \
                   python-pygments \
                   inkscape

# Add Titilium and Intro from the fonts folder
# You need to put otf and ttf files inside it
# first.
ADD fonts /usr/share/fonts

ARG uid=107
RUN useradd -u $uid builder

USER builder

WORKDIR /io

CMD /bin/bash
