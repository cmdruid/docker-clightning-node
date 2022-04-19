# clightning-node

A simple reference implementation of clightning, with Tor and REST API enabled.

## How to use

*Make sure that docker is installed, and you are part of docker group.*

```
git clone *this repository url*
cd clightning-node

# In bin/, add bitcoin and clightning binaries. More info below.
# In config/, rename sample.lightningd.conf to lightningd.conf, add your RPC credentials

./start.sh
```

The start script will launch the included Dockerfile inside a container, mount the `bin` folder, unpack the binaries and install all dependencies and configurations.

When finished, you will see two QR codes displayed: One for connecting to the REST interface via Tor, the other is the access macaroon. You will need these data to connect to a mobile wallet, such as Zeus. You will also see a stream of all pertinent logs for each running service. You can safely cancel out of this log by pressing Ctrl+C.

If you define the `BITCOIND_ONION` variable before running the script, then the container will forward all bitcoin-cli commands (used by clightning) to the specified tor address.

Example: `BITCOIND_ONION=address.onion:8332 ./start.sh`

### /bin

The start script will look for bitcoin and clightning binaries in this folder. These binaries can be built from source using my other project: https://github.com/cmdruid/docker-binary-builder

### /config

These files will be copied over and used to configure clightning and other services. If you want to modify the config files, simply run `./start.sh` with the `--build` or `--rebuild` flag, and the script will update your Dockerfile with the latest changes.

### /res

This folder contains scripts for downloading the pre-compiled binaries from each project's respective repo. This includes verifying checksums and signatures. For maximum compatibility, I would recommend building the binaries on your local machine instead.

### /startup

These scripts are copied into the `/root` folder when the docker image is built. Feel free to modify these existing scripts, or add your own!

## Contribution

All contributions are welcome! If you have any questions, feel free to send me a message or submit an issue.