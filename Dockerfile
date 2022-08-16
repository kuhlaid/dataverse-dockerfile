FROM rockylinux/rockylinux:latest
# install git and pull the latest developer code
RUN dnf install git-all
RUN git clone --depth 1 -b develop https://github.com/IQSS/dataverse
RUN cd dataverse
RUN ./conf/docker-aio/prep_it.bash
