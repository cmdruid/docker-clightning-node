#!/bin/sh
## Start script for lightning daemon.

###############################################################################
# Environment
###############################################################################

DATA_PATH="/data/lightning"
CONF_PATH="/root/.lightning/config"
BCLI_LINK="/root/.lightning/bitcoin"
CERT_PATH="/data/certs"
CERT_LINK="/root/rest-api/certs"
LOG_PATH="/var/log/lightningd.log"

DEFAULT_NETWORK="mainnet"
DEFAULT_RPC_HOST="127.0.0.1"
DEFAULT_RPC_PORT="8332"

###############################################################################
# Script
###############################################################################

DAEMON_PID=`pgrep lightningd`

if [ -z "$DAEMON_PID" ]; then

  ## Check if RPC credentials are set.
  if [ -z "$RPC_USER" ] || [ -z "$RPC_PASS" ]; then
    echo "Missing RPC credentials! Make sure user and password are set!"
    exit 1
  fi

  ## Set defaults.
  if [ -z "$NETWORK" ]; then NETWORK="$DEFAULT_NETWORK"; fi
  if [ -z "$RPC_HOST" ]; then RPC_HOST="$RPC_HOST"; fi
  if [ -z "$RPC_PORT" ]; then RPC_PORT="$RPC_PORT"; fi

  ## If host is set to an onion address, reset RPC host to localhost.
  if [ -n "$(echo $RPC_HOST | grep .onion)" ]; then RPC_HOST="127.0.0.1"; fi

  if [ ! -d "$DATA_PATH" ]; then 
    echo "Adding persistent data directory lightning daemon  ..."
    mkdir -p $DATA_PATH
  fi

  if [ ! -d "$CERT_PATH" ]; then 
    echo "Adding persistent data directory for rest certificates ..."
    mkdir -p $CERT_PATH
  fi

  ## Symlink the path for the bitcoin interface to persistent storage.
  if [ ! -e "$BCLI_LINK" ]; then
    echo "Adding symlink for bitcoin interface..."
    ln -s $DATA_PATH/bitcoin $BCLI_LINK
  fi

  ## Symlink the certificates for the REST API to persistent storage.
  if [ ! -e "$CERT_LINK" ]; then
    echo "Adding symlink for access macaroon ..."
    ln -s $CERT_PATH $CERT_LINK
  fi

  ## Start lightning in daemon mode.
  lightningd --daemon --$NETWORK --conf=$CONF_PATH \
    --bitcoin-rpcconnect=$RPC_HOST --bitcoin-rpcport=$RPC_PORT \
    --bitcoin-rpcuser=$RPC_USER --bitcoin-rpcpassword=$RPC_PASS

  ## Wait for lightningd to load, then start other services.
  tail -f $LOG_PATH | while read line; do
    echo "$line" && echo "$line" | grep "cl-rest api server is ready"
    if [ $? = 0 ]; then echo "Lightning daemon running on $NETWORK network!" && exit 0; fi
  done

else

  echo "Lightning daemon is running under PID: $DAEMON_PID"

fi