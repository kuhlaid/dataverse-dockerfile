# Still in development (not working)

> *These processes are currently failing, so this documentation will likely change. Docker is replaced by podman in RHEL environments and seems to be an issue trying to get the Docker commands to work with that, so ditching RockyLinux. Since WSL2 for Windows does not expose `systemd`, we cannot start up the Docker service which is needed. I have read some hacks that claim to get it running but that is not an ideal solution and I'm not willing to bother with it.*

## What does this repo do?

This is a test to determine if the Dataverse Project software can be built using Docker without the need to install `java11 compiler, maven, make, wget` locally on your computer. We want a Docker container to take care of this.

## How does the setup differ?

[only in concept phase] Other installs assume you have certain software installed on your system, and if you are a Windows user then you are out of luck because if you try to clone the Dataverse repository to your local computer, the code is converted to CRLF end of line characters (which kills your chances of working with the Docker instructions mentioned in the Dataverse Guides since they are Linux based). **What we need, is to run the Docker setup from WITHIN a Linux environment OR we need to download the repository from WITHIN Linux.** So by using this [Dockerfile](/Dockerfile), Windows developers can ensure they are building using the same processes for consistent testing and building of the Dataverse software environment. The [Dockerfile](/Dockerfile) in this repository creates a basic RockyLinux image with Git, Docker and WGET installed. This is the image you will use to run the Dataverse build command.

## New Docker approach 1/20/2023 (do not use Docker Desktop Dev Environment since it changes too much)

Beginning work on a `docker-compose.yml` using [https://github.com/IQSS/dataverse-docker/blob/master/docker-compose.yml] or [https://docs.docker.com/compose/gettingstarted/#step-3-define-services-in-a-compose-file]. The key might be using the `build: .` directive to run the Dockerfile for the image we need (we might want to place these Dockerfiles within subdirectories of the root).

Stick with the Dockerfile as the starting point so it is a consistent environment making the Git calls to pull the repository into Linux and then build out from there. Be sure to use the `depends_on:` command.

### Commands

Run `docker compose up` from this directory in your command terminal. This will first build our starter docker image which we will use to build our Dataverse environment (we do this first step for build consistency).


### Issues

I tried to run `systemctl list-unit-files |grep enabled` from within the `docker-starter` Docker container, but it does no show anything enabled (not sure if this is useful resource [https://docs.docker.com/config/daemon/systemd/]) or if not having anything enabled at this point is a problem.

























## [no longer works as of 1/19/2023] What are the steps to build a Dataverse host from scratch?

Within Docker Desktop, create a new Dev Environment using `https://github.com/kuhlaid/dataverse-dockerfile`. This will build the simple Linux Docker container mentioned above. Once the new container is built from `https://github.com/kuhlaid/dataverse-dockerfile`, we then open the terminal of this container in Docker Desktop and run:

```bash
cd com*
docker build -t starter .
```

*** NOTE: the `com` directory no longer seems to get included with Docker Desktop Dev Environment as of 1/20/2023 unless a compose.yaml file is included in the repository [https://docs.docker.com/compose/compose-file/]***

The `cd com*` command simply opens the directory where the code in this repository is saved in the Docker container. Note: Docker Desktop Dev Environment places code from GitHub under a `com.docker.devenvironments.code` directory so we use `cd com*` for short to open this directory. The `docker build -t starter .` command creates a Docker image named `starter` using the commands found in the [Dockerfile](/Dockerfile). Now that we have a `starter` Docker image, we need to run the `starter` image to create a container for it and open the terminal of the container, then run:

```bash
cd dataverse
./conf/docker-aio/prep_it.bash
```

The `cd dataverse` command opens the dataverse directory where the Dataverse software was downloaded from GitHub. The `./conf/docker-aio/prep_it.bash` command kicks off the build process of the Dataverse software.
