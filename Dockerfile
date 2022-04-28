FROM debian:bullseye-slim

ENV PATH="/root/.local/bin:$PATH"

## Install dependencies.
RUN apt-get update && apt-get install -y \
  curl git gnupg libsodium-dev procps qrencode socat xxd tor

## Configure directories.
RUN mkdir -p /root/app /root/.lightning /var/lib/tor /var/log/tor

COPY build/out/* /tmp/bin/
WORKDIR /tmp

## Unpack and install binaries.
RUN for file in /tmp/bin/*; do \
  if ! [ -z "$(echo $file | grep .tar.)" ]; then \
    echo "Unpacking $file to /usr ..." \
    && tar --wildcards --strip-components=1 -C /usr -xf $file \
  ; else \
    echo "Moving $file to /usr/bin ..." \
    && chmod +x $file && mv $file /usr/bin/ \
  ; fi \
; done

## Clean up temp files.
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you also want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Install Node.
RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash - \
  && apt-get install -y nodejs

## Install node packages.
RUN npm install -g npm

WORKDIR /root

## Install RTL REST API.
RUN git clone https://github.com/Ride-The-Lightning/c-lightning-REST.git rest-api
RUN cd rest-api && npm install

## Copy configuration files.
COPY config/torrc /etc/tor/
COPY config/lightningd.conf /root/.lightning/config

## Configure user account for Tor.
RUN addgroup tor \
  && adduser --system --no-create-home tor \
  && adduser tor tor \
  && chown -R tor:tor /var/lib/tor /var/log/tor

## Setup entrypoint for image.
COPY run /root/run
RUN chmod +x /root/run/*

ENTRYPOINT [ "/root/run/entrypoint.sh" ]
