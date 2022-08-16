FROM rockylinux/rockylinux:latest
# install git with `autoyes` Automatically answer yes for all questions
RUN dnf makecache --refresh
RUN dnf -y install wget
RUN dnf install --assumeyes git-all
# pull the latest developer code
RUN git clone --depth 1 -b develop https://github.com/IQSS/dataverse
RUN cd dataverse
ENTRYPOINT /./conf/docker-aio/prep_it.bash ; /bin/bash
# RUN ./conf/docker-aio/prep_it.bash
