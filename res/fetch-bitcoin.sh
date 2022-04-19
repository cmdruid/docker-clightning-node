#!/bin/sh
## Fetch binary from git repository.

set -e

###############################################################################
# Environment
###############################################################################

GITHUB_REPO="bitcoin/bitcoin"
RELEASES="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"/
DATA_DIR="$SCRIPT_DIR/data"
PLATFORM=`awk -v key="$(uname -m)" '$1==key {print $2}' $DATA_DIR/platforms.txt`

VERSION=`curl ${RELEASES} | grep 'tag_name' | sed 's/[^0-9.]*//g'`
SOFTWARE_URI="https://bitcoincore.org/bin/bitcoin-core-${VERSION}"

FILENAME="bitcoin-${VERSION}-${PLATFORM}.tar.gz"
BASENAME="$(echo $FILENAME | awk -F - '{print $1}')"

###############################################################################
# Script
###############################################################################

## Download gpg key from keyservers.
echo "Importing gpg keys from file..."
while read key; do
  while read server; do
    echo "Verifying key with server: $server"
    if $(gpg --batch --keyserver "$server" --recv-keys "$key" ); then
      break
    fi
  done < $DATA_DIR/key-servers.txt
done < $DATA_DIR/gpg-keys.txt

## Create bin folder if does not exist.
if [ ! -d "$SCRIPT_DIR/bin" ]; then
  mkdir -p "$SCRIPT_DIR/bin"
fi

## Enter bin directory and clean up existing files.
cd "$SCRIPT_DIR/bin" && rm -f SHA256SUMS*
echo "Fetching ${SOFTWARE_URI}/$FILENAME ..."

## Download software binaries and verify integrity.
curl -SLO "${SOFTWARE_URI}/$FILENAME"
curl -SLO "${SOFTWARE_URI}/SHA256SUMS"
curl -SLO "${SOFTWARE_URI}/SHA256SUMS.asc"

gpg --verify SHA256SUMS.asc SHA256SUMS
grep "$FILENAME" SHA256SUMS | sha256sum -c -

## Clean up excess files.
rm SHA256SUMS*

echo "Finished download of $FILENAME!"
