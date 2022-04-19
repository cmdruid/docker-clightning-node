FROM debian:bullseye-slim

ENV PATH="/root/.local/bin:$PATH"

## Configure directories.
RUN mkdir -p /root/app /data/certs /data/tor /data/lightning/bitcoin /root/.lightning

## Install dependencies.
RUN apt-get update && apt-get install -y \
  curl git gnupg libsodium-dev procps qrencode socat xxd tor

# libsodium-dev libpq
COPY bin/* /tmp/
WORKDIR /tmp

## Install bitcoin-cli binary.
RUN tar --wildcards --strip-components=1 -C /usr -xf \
  bitcoin*.tar.gz bitcoin*/bin/bitcoin-cli \
  && which bitcoin-cli | grep bitcoin-cli

## Install clightning binaries.
RUN tar --wildcards --strip-components=1 -C /usr -xf \
clightning*.tar.gz \
  && which lightningd | grep lightningd

## Install Node.
RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash - \
  && apt-get install -y nodejs

## Install node packages.
RUN npm install -g npm

## Install RTL REST API.
RUN cd /root/app \
  && git clone https://github.com/Ride-The-Lightning/c-lightning-REST.git rest-api \
  && cd rest-api && npm install

## Clean up temp files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you also want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Copy configuration files.
COPY config/torrc /etc/tor/
COPY config/lightningd.conf /root/.lightning/config

## Configure user account for Tor.
RUN addgroup tor \
  && adduser --system --no-create-home tor \
  && adduser tor tor \
  && chown -R tor:tor /data/tor /var/log/tor

## Setup entrypoint for image.
COPY startup/* /root/
RUN chmod +x /root/*

WORKDIR /root

## Clone RTL REST 
ENTRYPOINT [ "./entrypoint.sh" ]
