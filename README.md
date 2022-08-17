# What does this repo do?

This is a test to determine if the Dataverse Project software can be built using Docker. 

## How does the setup differ?

Other installs assume you have certain software installed on your system, and if you are a Windows user then you are out of luck because if you try to clone the Dataverse repository the code is all converted to CRLF end of line characters (which kills your chances of working with the Docker instructions mentioned in the Dataverse Guides). We need to run the Docker setup from WITHIN a Linux environment. So by creating this [Dockerfile](/Dockerfile), Windows developers can ensure they are  The [Dockerfile](/Dockerfile) in this repository creates a RockyLinux image that doesn't does the work of pulling the Dataverse software into a Docker image.

## What are the steps to build a Dataverse host?

Within Docker Desktop, create a new Dev Environment using `https://github.com/kuhlaid/dataverse-dockerfile`. This will build a simple Linux Docker container with the files from this repo, and we will use this container to run the [Dockerfile](/Dockerfile) since we need commands run from a consistent source for testing. To run the [Dockerfile](/Dockerfile) open the terminal of your new container in Docker Desktop and run:

```bash
cd com*
docker build -t starter .
```

Note: Docker Desktop Dev Environment places code from GitHub under a `com.docker.devenvironments.code` directory so we use `cd com*` for short to open this directory.
Now we have a `starter` Docker image we need to run the `starter` image (create a container) and open the terminal of the container to run:

```bash
cd dataverse
./conf/docker-aio/prep_it.bash
```

These commands will open the root directory of the Dataverse code and then execute the `prep_it.bash` script to begin the Dataverse software build process.

> *These processes are currently failing on the Maven build, so this documentation will likely change.*
