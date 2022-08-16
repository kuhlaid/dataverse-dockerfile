FROM rockylinux/rockylinux:latest
# install git with `autoyes` Automatically answer yes for all questions
RUN dnf makecache --refresh
RUN dnf -y install wget
RUN dnf -y install docker
RUN dnf install --assumeyes git-all
# pull the latest developer code from the `docker-build` branch
RUN git clone --branch docker-build --depth 1 -b develop https://github.com/kuhlaid/dataverse.git
# RUN cd dataverse
# ENTRYPOINT ./conf/docker-aio/prep_it.bash ; /bin/bash (does not work)
# RUN /bin/bash -c ./conf/docker-aio/prep_it.bash (does not work)
# RUN /bin/bash -c /dataverse/conf/docker-aio/prep_it.bash (does not work)
# CMD ["/dataverse/conf/docker-aio/prep_it.bash"] (does not work)
# CMD ["./conf/docker-aio/prep_it.bash"] (Docker disliked this one)
# CMD ["conf/docker-aio/prep_it.bash"] (no good)
# CMD ["sh", "-c", "./conf/docker-aio/prep_it.bash"] (sh: ./conf/docker-aio/prep_it.bash: No such file or directory)
# CMD ./conf/docker-aio/prep_it.bash (/bin/sh: ./conf/docker-aio/prep_it.bash: No such file or directory)
# CMD cd dataverse | ./conf/docker-aio/prep_it.bash (/bin/sh: ./conf/docker-aio/prep_it.bash: No such file or directory)
# CMD ls


# -------- this file is used as our development starter because we want a reproducible starting environment to build our dataverse software
