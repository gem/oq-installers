FROM fedora:29
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -y install java-1.8.0-openjdk openssh-server \
           bzip2 findutils git tar dnf-utils copr-cli mock && \ 
           dnf clean all && \
           find /var/cache/dnf -type f -delete

RUN ssh-keygen -A && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd  && \ 
    useradd -u 1000 jenkins && \
    usermod -a -G mock jenkins

RUN echo "config_opts['use_nspawn'] = False" >> /etc/mock/site-defaults.cfg
ADD openquake.cfg /etc/mock
ADD copr /home/jenkins/.config/copr
ADD ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
RUN chown -R jenkins.jenkins /home/jenkins && \
    chmod 640 /home/jenkins/.config/* && \
    chmod 700 /home/jenkins/.ssh && \
    chmod 600 /home/jenkins/.ssh/*

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
