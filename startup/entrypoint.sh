#!/bin/sh
## Entrypoint script for image.

###############################################################################
# Methods
###############################################################################

start_daemon() {
  ## Start program as a daemon service.
  pkill $1
  $1 $2 > /var/log/$1.log & echo "$!" > /var/log/$1.pid
}

print_onion_addr() {
  ONION_ADDR="$(cat /data/tor/services/rest/hostname):3001"
  printf "
Onion Address:\n$ONION_ADDR\n
`echo $ONION_ADDR | qrencode -m 2 -t utf8`\n
  "
}

print_hex_macaroon() {
  MACAROON_FILE="/data/certs/access.macaroon"
  HEX_CODE=`xxd -ps -u -c 1000 $MACAROON_FILE`
  printf "
Macaroon Hex Code:\n$HEX_CODE\n
`echo $HEX_CODE | qrencode -m 2 -t utf8`\n
  "
}

###############################################################################
# Script
###############################################################################

## Create tor data directory if missing.
TOR_DIR="/data/tor"
if [ ! -d "$TOR_DIR/services" ]; then
  echo "Adding tor data directories ..."
  mkdir -p -m 700 $TOR_DIR/services
  chown -R tor:tor $TOR_DIR
fi

start_daemon tor

## Wait for Tor to load, then start other services.
tail -f /var/log/tor.log | while read line; do
  echo "$line" && echo "$line" | grep "Bootstrapped 100%"
  if [ $? = 0 ]; then 
    echo "Tor circuit initialized!" && exit 0
  fi
done

## Symlink theese paths to the data store for compatibility.
ln -s /data/certs /root/app/rest-api/certs
ln -s /data/lightning/bitcoin /root/.lightning/bitcoin

## Setup a socet for connecting to bitcoind over tor.
if [ ! -z "$BITCOIND_ONION" ]; then
  start_daemon socat "tcp-listen:8332,reuseaddr,fork socks4a:127.0.0.1:$BITCOIND_ONION,socksport=9050"
fi

## Start lightning in daemon mode.
start_daemon lightningd "--daemon --mainnet --conf=/root/.lightning/config"

## Print connection information.
print_onion_addr
print_hex_macaroon

## Tail log files of running services.
tail -f /var/log/tor.log /var/log/lightningd.log