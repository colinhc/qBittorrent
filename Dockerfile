# docker build ./ -t :nox
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y build-essential pkg-config automake libtool zlib1g-dev libssl-dev libgeoip-dev \
        libboost-dev libboost-system-dev libboost-random-dev python3 \
    && apt install -y qtbase5-dev qtbase5-private-dev qttools5-dev libqt5svg5-dev \
    && apt install -y libtorrent-rasterbar-dev

RUN apt install -y curl tree vim \
    && apt clean && rm -rf /var/lib/opt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /qbt/github
COPY ./ /qbt/github
WORKDIR /qbt/github
RUN ./configure --disable-gui --prefix=/usr
RUN make -j$(nproc) && make install

EXPOSE 8089

ONBUILD WORKDIR /qbt
ONBUILD RUN rm -rf github
