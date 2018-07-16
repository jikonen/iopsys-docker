#FROM ubuntu:16.04
FROM phusion/baseimage:0.10.1

ENV HOME /home/build
ENV USER build

# No cache
COPY docker-files/02nocache /etc/apt/apt.conf.d/

# No docs
COPY docker-files/01_nodoc /etc/dpkg/dpkg.cfg.d/

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install required packages
RUN apt-get -y update && apt-get -y install git sudo bison build-essential ccache execstack flex g++ g++-multilib gawk gettext git automake gtk-doc-tools liblzo2-dev libncurses5-dev libssl-dev ncurses-term python subversion svn-buildpackage unzip uuid-dev wget zlib1g-dev libconvert-binary-c-perl libdigest-crc-perl libc6-dev-i386 lib32z1 nodejs yui-compressor curl locales vim

# Install toolchains
RUN install -d /opt/toolschains
RUN cd /tmp && wget http://iopsys.inteno.se/iopsys/toolchain/crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2 && tar jxf crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2 && tar -Pjxf crosstools-mips-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2.tar.bz2 && tar -Pjxf crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL.Rel1.2.tar.bz2
RUN rm -f crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-sources.tar.bz2 crosstools-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2-full.tar.bz2 crosstools-mip*-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21.Rel1.2.tar.bz2 crosstools-arm-gcc-4.6-linux-3.4-uclibc-0.9.32-binutils-2.21-NPTL.Rel1.2.tar.bz2

# Add build user and give hime sudo with no passwd
RUN useradd --create-home --home-dir $HOME build && chown -R build:build $HOME && adduser build sudo
RUN echo "build ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/build

RUN install -d /home/build/.ssh/
COPY docker-files/id_rsa* /home/build/.ssh/
COPY docker-files/bash_aliases /home/build/.bash_aliases
COPY docker-files/localdir-to-path.sh /etc/profile.d/localdir-to-path.sh

RUN locale-gen en_US.UTF-8

COPY docker-files/init.iopsys /init.iopsys

# Fix permissions
RUN chown -Rf build.build /opt/toolchains /home/build/

# Clean up and remove unneeded
RUN apt-get autoremove && apt-get autoclean && apt-get clean 
USER build
CMD ["/sbin/my_init"]
