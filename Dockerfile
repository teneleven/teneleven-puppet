FROM ubuntu:14.04

#Optional, update mirrors speedups updates, but some mirrors sometimes fail
#RUN sed -i -e 's,http://[^ ]*,mirror://mirrors.ubuntu.com/mirrors.txt,' /etc/apt/sources.list

#update apt sources
RUN apt-get update --fix-missing

#install required packages
RUN apt-get install -y \
        apt-utils \
        curl \
        wget \
        nfs-common \
        apt-transport-https \
        lxc \
        supervisor \
    && apt-get clean #cleanup to reduce image size

# Puppet
RUN wget http://apt.puppetlabs.com/puppetlabs-release-stable.deb -O /tmp/puppetlabs-release-stable.deb && \
    dpkg -i /tmp/puppetlabs-release-stable.deb && \
    apt-get update && \
    apt-get install puppet puppet-common hiera facter virt-what lsb-release  -y --force-yes && \
    rm -f /tmp/*.deb && \
    apt-get clean

VOLUME /puppet
COPY   provision.sh /provision.sh

WORKDIR /

# simple puppet apply command & supervisor to keep container running
CMD /provision.sh; supervisord -n
