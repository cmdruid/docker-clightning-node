#!/bin/sh
## Startup script for docker container.

set -e

###############################################################################
# Environment
###############################################################################

NAME="clightning-node"
ENV_STRING=""

###############################################################################
# Methods
###############################################################################

build_image() {
  echo "Building $NAME from dockerfile ..."
  docker build --tag $NAME .
}

stop_container() {
  ## Check if previous container exists, and remove it.
  if docker container ls -a | grep $NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $NAME > /dev/null 2>&1
    docker container rm $NAME > /dev/null 2>&1
  fi
}

###############################################################################
# Script
###############################################################################

## Create build/out path if missing.
if [ ! -d "build/out" ]; then mkdir -p build/out; fi

## For each dockerfile, check if binary is present.
for file in build/dockerfiles/*; do
  name="$(basename -s .dockerfile $file)"
  if [ -z "$(ls build/out | grep $name)" ]; then
    build/build.sh $file
  fi
done

## If existing image is not present, build it.
if [ -z "$(docker image ls | grep $NAME)" ] || [ "$1" = "--build" ]; then
  build_image
elif [ "$1" = "--rebuild" ]; then
  docker image rm $NAME > /dev/null 2>&1
  build_image
fi

## Convert environment file into string.
if [ -e "$(pwd)/.env" ]; then
  ENV_STRING=`
    while read line || [ -n "$line" ]; do 
      echo "-e $line "
    done < .env
  `
fi

## Make sure to stop any existing container.
stop_container

## Start container in runtime configuration.
echo "Starting container for $NAME ... "
docker run -d \
  --name $NAME \
  --hostname $NAME \
  --mount type=volume,source=$NAME-data,target=/data \
  --mount type=bind,source=$(pwd)/run,target=/root/run \
  --restart unless-stopped \
$ENV_STRING $NAME:latest

# printf "\n
# =============================================================================
#   Now viewing log output of $NAME container. Press Ctrl+C to exit.
#   Administer this container by running 'docker exec -it $NAME bash'
# =============================================================================
# \n\n"

## Start tailing logs for container.
docker logs -f $NAME

#  
