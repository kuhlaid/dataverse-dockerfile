# pull from https://hub.docker.com/_/debian/
# we need to use Debian bullseye v11
FROM debian:stable
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
    
# RUN sudo apt -y install wget
# RUN sudo apt -y install docker
# RUN sudo apt -y install git-all

# trying a Debian branch of the Docker build
ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-debian version.json
RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-debian --single-branch

# run `cat /etc/os-release` to check the OS version after the container is built


# pull the latest developer code from the `docker-build` branch
# RUN git clone --branch docker-build https://github.com/kuhlaid/dataverse.git (not having luck with this one due to Maven plugin failing at the end)

# try to prevent Docker from caching the Dataverse code (this uses RockyLinux which uses Podman instead of Docker and seems to be causing problems with the build so switching to Debian OS)
# ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-build version.json
# RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-build --single-branch

# trying latest Dataverse develop codebase
# RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-aio-orig --single-branch
# -------- this file is used as our development starter because we want a reproducible starting environment to build our dataverse software
