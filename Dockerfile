# pull from https://hub.docker.com/_/debian/
# we need to use Debian bullseye v11
FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive

# Constants
ARG PAYARA_VERSION=5.201
ARG PAYARA_PKG=https://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara-web/${PAYARA_VERSION}/payara-web-${PAYARA_VERSION}.zip
ARG PAYARA_SHA1=4c5122befc9f55969f5a332dd6e16979cda7c94f
ARG POSTGRESQL_VERSION=13
ARG SOLR_VERSION=8.11.1

# install some of the basics we will need
RUN apt-get update && apt-get install -y \
    git \
    lsb-release \
    gnupg2 \
    unzip \
    nano \
    openjdk-11-jdk \
    wget

# install payara web server (reference https://hub.docker.com/r/payara/server-web/dockerfile)
RUN useradd dataverse && \
    wget --no-verbose -O payara.zip ${PAYARA_PKG} && \
    echo "${PAYARA_SHA1} *payara.zip" | sha1sum -c - && \
    unzip -qq payara.zip -d ./ && \
    mv payara*/ /usr/local && \
    chown -R root:root /usr/local/payara5 && \
    chown dataverse /usr/local/payara5/glassfish/lib && \
    chown -R dataverse:dataverse /usr/local/payara5/glassfish/domains/domain1
    # nano /usr/local/payara5/glassfish/domains/domain1/config/domain.xml (as mentined in [https://guides.dataverse.org/en/latest/installation/prerequisites.html])

# install postgresql (v13) database
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install "postgresql-${POSTGRESQL_VERSION}"
    # check the installed version by using the command `psql -V psql`

# install Solr (search engine)
RUN useradd solr && \
    mkdir /usr/local/solr && \
    chown solr:solr /usr/local/solr && \
    su - solr && \
    cd /usr/local/solr && \
    wget https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz && \
    tar xvzf solr-${SOLR_VERSION}.tgz && \
    cd solr-${SOLR_VERSION} && \
    cp -r server/solr/configsets/_default server/solr/collection1
    # `nano usr/local/solr/solr-8.11.1/server/etc/jetty.xml`
    # replace requestHeaderSize in the `usr/local/solr/solr-8.11.1/server/etc/jetty.xml` file
    sed -i 's,Set name="requestHeaderSize"><Property name="solr.jetty.request.header.size" default="8192" /></Set,Set name="requestHeaderSize"><Property name="solr.jetty.request.header.size" default="102400" /></Set,g' usr/local/solr/solr-8.11.1/server/etc/jetty.xml


## things we might need to do?
# `find . -name pg_hba.conf`
# `nano /etc/postgresql/15/main/pg_hba.conf`
# not sure if we need to change the `host all all 127.0.0.1/32 md5` as mentioned in [https://guides.dataverse.org/en/latest/installation/prerequisites.html]

# trying a Debian branch of the Docker build and prevent Docker from caching the Dataverse code
ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-debian version.json
RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-debian --single-branch


## things to c