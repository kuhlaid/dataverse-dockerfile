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

# install some of the basics our environment will need (seem to need `libssl-dev` and `libcurl4-openssl-dev` for one of the R packages)
RUN apt-get update && apt-get install -y \
    git \
    gnupg2 \
    imagemagick \
    jq \
    lsb-release \
    nano \
    openjdk-11-jdk \
    libssl-dev \
    libcurl4-openssl-dev \
    pip \
    python3-venv \
    r-base \
    unzip \
    wget

# install payara web server (reference https://hub.docker.com/r/payara/server-web/dockerfile)
RUN useradd dataverse && \
    wget --no-verbose -O payara.zip ${PAYARA_PKG} && \
    echo "${PAYARA_SHA1} *payara.zip" | sha1sum -c - && \
    unzip -qq payara.zip -d ./ && \
    mv payara*/ /usr/local && \
    chown -R root:root /usr/local/payara5 && \
    chown dataverse /usr/local/payara5/glassfish/lib && \
    chown -R dataverse:dataverse /usr/local/payara5/glassfish/domains/domain1 &&\
    # nano /usr/local/payara5/glassfish/domains/domain1/config/domain.xml (as mentined in [https://guides.dataverse.org/en/latest/installation/prerequisites.html])
    sed -i 's,<jvm-options>-client</jvm-options>,<jvm-options>-server</jvm-options>,g' /usr/local/payara5/glassfish/domains/domain1/config/domain.xml

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
    cp -r server/solr/configsets/_default server/solr/collection1 && \
    # `nano usr/local/solr/solr-${SOLR_VERSION}/server/etc/jetty.xml` if you wish to check the settings
    # replace requestHeaderSize in the `usr/local/solr/solr-${SOLR_VERSION}/server/etc/jetty.xml` file
    sed -i 's,Set name="requestHeaderSize"><Property name="solr.jetty.request.header.size" default="8192" /></Set,Set name="requestHeaderSize"><Property name="solr.jetty.request.header.size" default="102400" /></Set,g' /usr/local/solr/solr-${SOLR_VERSION}/server/etc/jetty.xml &&\
    # tell Solr to create the core “collection1” on startup
    echo "name=collection1" > /usr/local/solr/solr-${SOLR_VERSION}/server/solr/collection1/core.properties &&\
    # might need to update `/etc/security/limits.conf` ???
    # get Solr Init Script
    cd /tmp &&\
    wget https://raw.githubusercontent.com/IQSS/dataverse/develop/doc/sphinx-guides/source/_static/installation/files/etc/systemd/solr.service &&\
    cp /tmp/solr.service /etc/systemd/system &&\
    # systemctl daemon-reload &&\
    # systemctl start solr.service &&\
    # systemctl enable solr.service &&\
    # We additionally recommend that the Solr service account’s shell be disabled, as it isn’t necessary for daily operation
    usermod -s /sbin/nologin solr


# install jq
# RUN cd /usr/bin &&\
#     wget http://stedolan.github.io/jq/download/linux64/jq &&\
#     chmod +x jq &&\
#     jq --version

# `jq --version` (checks jq version)
# `convert -version` (checks imagemagick version)

# install R required packages
RUN R -e "options(warn=2); install.packages('R2HTML',dependencies=TRUE, repos='https://cran.r-project.org/')"
RUN R -e "options(warn=2); install.packages('rjson',dependencies=TRUE, repos='https://cran.r-project.org/')"
## DescTools is not supported in Linux
# RUN R -e "options(warn=2); install.packages('DescTools',dependencies=TRUE, repos='https://cran.r-project.org/')"
RUN R -e "options(warn=2); install.packages('RSclient',dependencies=TRUE, repos='https://cran.r-project.org/')"
RUN R -e "options(warn=2); install.packages('Rserve',dependencies=TRUE, repos='https://cran.r-project.org/')"
RUN R -e "options(warn=2); install.packages('haven',dependencies=TRUE, repos='https://cran.r-project.org/')"

# install https://github.com/CDLUC3/counter-processor
# RUN cd /usr/local &&\
#     git clone https://github.com/CDLUC3/counter-processor.git &&\
#     cd counter-processor &&\
#     git checkout branch-or-tag

# skipping GeoLite Country configuration
# RUN wget https://web.archive.org/web/20191222130401/https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz &&\
#     tar zxvf GeoLite2-Country.tar.gz # extract the database
#     # copy it to the maxmind_geoip directory inside the app for defaults
#     cp GeoLite2-Country_<em>release-date</em>/GeoLite2-Country.mmdb <app_directory>/maxmind_geoip</pre>

## things we might need to do?
# `find . -name pg_hba.conf`
# `nano /etc/postgresql/15/main/pg_hba.conf`
# not sure if we need to change the `host all all 127.0.0.1/32 md5` as mentioned in [https://guides.dataverse.org/en/latest/installation/prerequisites.html]

# trying a Debian branch of the Docker build and prevent Docker from caching the Dataverse code
# ADD https://api.github.com/repos/kuhlaid/dataverse/git/refs/heads/docker-debian version.json
# RUN git clone https://github.com/kuhlaid/dataverse.git --branch docker-debian --single-branch

# trying to clone directly from the developer branch
ADD https://api.github.com/repos/IQSS/dataverse/git/refs/heads/develop version.json
RUN git clone https://github.com/IQSS/dataverse.git --branch develop --single-branch

# configure RServe now that we have the Dataverse code
RUN cd /dataverse/scripts/r/rserve &&\
    ./rserve-setup.sh
    
# run the Dataverse installer
RUN cd /dataverse/scripts/installer
RUN python3 -m venv venv
#     # the `source` command needs the bash shell
SHELL ["/bin/bash", "-c"]
RUN source venv/bin/activate
RUN pip install psycopg2-binary
RUN cd /dataverse/scripts/installer

## this is where a WAR file in needed and there are no simple instructions on building the WAR file
# RUN python3 install.py
