#!/bin/sh
## Fetch binary from git repository.

set -e

###############################################################################
# Environment
###############################################################################

GITHUB_REPO="ElementsProject/lightning"
RELEASES="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"/
DATA_DIR="$SCRIPT_DIR/data"

VERSION=`curl ${RELEASES} | grep 'tag_name' | sed 's/[^0-9.]*//g'`
SOFTWARE_URI="https://github.com/$GITHUB_REPO/releases/download/v$VERSION"
KEYS_URI="https://raw.githubusercontent.com/$GITHUB_REPO/master/contrib/keys"

FILENAME="clightning-v$VERSION-Ubuntu-20.04.tar.xz"
BASENAME="$(echo $FILENAME | awk -F - '{print $1}')"

###############################################################################
# Script
###############################################################################

## Download gpg key from keyservers.
echo "Importing pgp keys..."
while read keyfile; do
  KEY=`curl $KEYS_URI/$keyfile | gpg --import -`
done < $DATA_DIR/pgp-keys.txt

## Create bin folder if does not exist.
if [ ! -d "$SCRIPT_DIR/bin" ]; then
  mkdir -p "$SCRIPT_DIR/bin"
fi

## Enter bin directory and clean up existing files.
cd "$SCRIPT_DIR/bin" && rm -f SHA256SUMS*
echo "Fetching ${SOFTWARE_URI}/$FILENAME ..."

curl -SLO "$SOFTWARE_URI/$FILENAME"
curl -SLO "$SOFTWARE_URI/SHA256SUMS"
curl -SLO "$SOFTWARE_URI/SHA256SUMS.asc"

gpg --verify SHA256SUMS.asc SHA256SUMS
grep "$FILENAME" SHA256SUMS | sha256sum -c -

## Clean up excess files.
rm SHA256SUMS*

echo "Finished download of $FILENAME!"
