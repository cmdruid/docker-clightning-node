#!/bin/sh
## Start script for socat.

###############################################################################
# Environment
###############################################################################

LOG_PATH="/var/log/socat.log"

DEFAULT_RPC_PORT="8332"

###############################################################################
# Script
###############################################################################

DAEMON_PID=`pgrep socat`

if [ -z "$DAEMON_PID" ]; then
  
  if [ -n "$(echo $RPC_HOST | grep .onion)" ]; then

    if [ -z "$RPC_PORT" ]; then RPC_PORT="$DEFAULT_RPC_PORT"; fi

    ## Setup a socet for connecting to bitcoind over tor.
    socat -lf $LOG_PATH tcp-listen:$RPC_PORT,reuseaddr,fork \
    socks4a:127.0.0.1:$RPC_HOST:$RPC_PORT,socksport=9050 \
    & echo "Socat forwarding 127.0.0.1:$RPC_PORT -> $RPC_HOST:$RPC_PORT"

  fi
  
else

  echo "Socat process is running under PID: $DAEMON_PID"

fi