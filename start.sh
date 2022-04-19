#!/bin/sh
## Startup script for docker container.

###############################################################################
# Environment
###############################################################################

IMG_NAME="clightning-node"
IMG_VER="latest"
SERV_NAME=$IMG_NAME

###############################################################################
# Methods
###############################################################################

build_image() {
  echo "Building $IMG_NAME from dockerfile ..."
  docker build --tag $IMG_NAME .
}

stop_container() {
  ## Check if previous container exists, and remove it.
  if docker container ls | grep $SERV_NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $SERV_NAME > /dev/null 2>&1
  fi
}

###############################################################################
# Script
###############################################################################

set -e

## If existing image is not present, build it.
if [ -z "$(docker image ls | grep $IMG_NAME)" ] || [ "$1" = "--build" ]; then
  build_image
elif [ "$1" = "--rebuild" ]; then
  docker image rm $IMG_NAME > /dev/null 2>&1
  build_image
fi

## Stop any existing containers.
stop_container

echo "Starting $SERV_NAME container... "

  ## Start container in runtime configuration.
  docker run -d --rm \
    --name $SERV_NAME \
    --hostname $SERV_NAME \
    --mount type=bind,source=$pwd/bin,target=/tmp/bin \
    --mount type=volume,source=$SERV_NAME-data,target=/data \
    -e BITCOIND_ONION=$BITCOIND_ONION \
  $IMG_NAME:$IMG_VER

  printf "\n
  =========================================================================
    Now viewing log output of $SERV_NAME container. Press Ctrl+C to exit.
    Administer this container by running 'docker exec -it $SERV_NAME bash'
  =========================================================================
  \n\n"

  docker logs -f $SERV_NAME

fi
