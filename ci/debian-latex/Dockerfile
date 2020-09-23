FROM debian:buster
MAINTAINER Antonio Ettorre <ettorre@openquake.org>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q && apt-get install -qy \
    texlive-full \
    poppler-utils \
    python3-pygments \
    inkscape \
    && rm -rf /var/lib/apt/lists/*

ADD fonts /usr/share/fonts
WORKDIR /io

CMD /bin/bash
