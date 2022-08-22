# pull from https://hub.docker.com/_/debian/
# we need to use Debian bullseye v11
FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive
# these were old RockyLinux commands (removed since Docker is replaced with Podman in RHEL environments)
# RUN dnf makecache --refresh
# RUN dnf -y install wget
# RUN dnf -y install docker
# RUN dnf install --assumeyes git-all

RUN apt-get update && apt-get install -y \
    docker \
    git \
    wget
    
# trying to enable systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
rm -f /lib/systemd/system/multi-user.target.wants/;
rm -f /etc/systemd/system/.wants/;
rm -f /lib/systemd/system/local-fs.target.wants/;
rm -f /lib/systemd/system/sockets.target.wants/udev;
rm -f /lib/systemd/system/sockets.target.wants/initctl;
rm -f /lib/systemd/system/basic.target.wants/;
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]
CMD ["/usr/sbin/init"]

# trying a Debian branch of the Docker build and prevent Docker from caching the Dataverse code
ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-debian version.json
RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-debian --single-branch

# run `cat /etc/os-release` to check the OS version after the container is built
