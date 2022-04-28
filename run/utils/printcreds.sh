#!/bin/sh
## Print current RPC credentials.

###############################################################################
# Environment
###############################################################################

HOST_ONION_PATH="/data/tor/services/rest/hostname"
HOST_AUTH_PATH="/data/certs/access.macaroon"

###############################################################################
# Methods
###############################################################################

print_qr_code() {
  QR_CODE=`echo $1 | qrencode -m 2 -t ANSIUTF8`
  printf "\n$2\n\n$QR_CODE\n\n"
}

###############################################################################
# Script
###############################################################################

ONION_ADDR="$(cat $HOST_ONION_PATH):3001"
AUTH_CODE=`cat $HOST_AUTH_PATH | xxd -ps -c 10000`

printf "
===============================================================================
  REST endpoint: $ONION_ADDR
  Access token: $AUTH_CODE
===============================================================================
"

print_qr_code $ONION_ADDR "Scan for REST endpoint:"
print_qr_code $AUTH_CODE "Scan for access token (hex):"