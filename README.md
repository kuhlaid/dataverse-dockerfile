# What does this repo do?

This is a test to determine if the Dataverse Project software can be built using Docker. 

## How does the setup differ?

Other installs assume you have certain software installed on your system, and if you are a Windows user then you are out of luck because if you try to clone the Dataverse repository the code is all converted to CRLF end of line characters (which kills your chances of working with the Docker instructions mentioned in the Dataverse Guides). We need to run the Docker setup from WITHIN a Linux environment. So by creating this [Dockerfile](/Dockerfile), Windows developers can ensure they are  The [Dockerfile](/Dockerfile) in this repository creates a RockyLinux image that doesn't does the work of pulling the Dataverse software into a Docker image.

## What are the steps to build a Dataverse host?

Within Docker Desktop, create a new Dev Environment using `https://github.com/kuhlaid/dataverse-dockerfile`. This will build a simple RockyLinux Docker container for running the Dataverse Software build process.

Next open the terminal of your new container in Docker Desktop and run:

Now we have a `starter` Docker image:
`cd dataverse`
`./conf/docker-aio/prep_it.bash`

These commands will open the root directory of the Dataverse code and then execute the `prep_it.bash` script to begin the Dataverse software build process. 
