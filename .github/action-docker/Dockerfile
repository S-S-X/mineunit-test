FROM alpine:latest as build
USER root
ENV USER=root
RUN apk add --no-cache build-base git lua-dev luarocks5.1 lua5.1-sec
RUN luarocks-5.1 install luasocket
RUN luarocks-5.1 install luacov
RUN luarocks-5.1 install luassert
RUN luarocks-5.1 install busted 2.0.0-1

#COPY . /build/mineunit
#RUN cd /build/mineunit && luarocks-5.1 make
RUN luarocks-5.1 install --server=https://luarocks.org/dev mineunit

RUN mineunit --fetch-core 5.4.1
RUN mineunit --fetch-core 5.5.1
RUN mineunit --fetch-core 5.6.1
RUN mineunit --fetch-core 5.7.0

# Mineunit base
FROM alpine:latest
COPY --from=build /usr/local /usr/local
RUN adduser -D mineunit
RUN mkdir -p /usr/local/share/lua/5.1/mineunit/core
RUN chown mineunit /usr/local/share/lua/5.1/mineunit/core
RUN apk add --no-cache lua5.1 bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
#USER mineunit
#WORKDIR /home/mineunit

ENTRYPOINT ["/entrypoint.sh"]