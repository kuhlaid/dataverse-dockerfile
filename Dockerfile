FROM rockylinux/rockylinux:latest
# install git with `autoyes` Automatically answer yes for all questions
RUN dnf makecache --refresh
RUN dnf -y install wget
RUN dnf -y install docker
RUN dnf install --assumeyes git-all
# pull the latest developer code from the `docker-build` branch
# RUN git clone --branch docker-build https://github.com/kuhlaid/dataverse.git (not having luck with this one due to Maven plugin failing at the end)

# try to prevent Docker from caching the Dataverse code
ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-build version.json
RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-build --single-branch

# trying latest Dataverse develop codebase
# RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-aio-orig --single-branch
# -------- this file is used as our development starter because we want a reproducible starting environment to build our dataverse software
