FROM centos:8
MAINTAINER Daniele Viganò <daniele@openquake.org>

RUN dnf -y install epel-release && \
    dnf -y install java-1.8.0-openjdk openssh-server \
           bzip2 findutils git tar dnf-utils copr-cli mock && \ 
    dnf clean all && \
    find /var/cache/dnf -type f -delete

# 'rm /run/nologin' is usually done by systemd at the end of boot
# but here systemd is not executed so it must be deleted manually
RUN ssh-keygen -A && \
    mkdir -p /var/run/sshd && \
    rm /run/nologin && \
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
