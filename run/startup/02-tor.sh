#!/bin/sh
## Startup script for tor.

###############################################################################
# Environment
###############################################################################

DATA_PATH="/data/tor"
CONF_PATH="/etc/tor/torrc"
COOK_PATH="/var/lib/tor"
LOG_PATH="/var/log/tor/notice.log"

###############################################################################
# Script
###############################################################################

DAEMON_PID=`pgrep tor`

if [ -z "$DAEMON_PID" ]; then

  ## If missing, create tor services path.
  if [ ! -d "$DATA_PATH/services" ]; then
    echo "Adding persistent data directory for tor ..."
    mkdir -p -m 700 $DATA_PATH/services
    chown -R tor:tor $DATA_PATH
  fi

  # ## If missing, create tor cookie path.
  # if [ ! -d "$COOK_PATH" ]; then
  #   echo "Adding cookie directory for tor ..."
  #   mkdir -p -m 700 $COOK_PATH
  # fi

  ## Make sure permissions are correct.
  #echo "Enforcing permissions on tor directories ..."
  
  #chown -R tor:tor $COOK_PATH

  ## Start tor then tail the logfile to search for the completion phrase.
  echo "Starting tor process..."
  tor -f $CONF_PATH; tail -f $LOG_PATH | while read line; do
    echo "$line" && echo "$line" | grep "Bootstrapped 100%"
    if [ $? = 0 ]; then echo "Tor circuit initialized!" && exit 0; fi
  done

else

  echo "Tor daemon is running under PID: $DAEMON_PID"

fi