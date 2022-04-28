#!/bin/sh
## Entrypoint script for image.

set -e

###############################################################################
# Environment
###############################################################################

WORKDIR="$(dirname "$(realpath "$0")")"

###############################################################################
# Script
###############################################################################

## Execute startup scripts
for script in $WORKDIR/startup/*.sh; do
  #echo "Executing $script"
  WORKDIR=$WORKDIR sh $script
done