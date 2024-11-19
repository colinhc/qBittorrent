# docker build ./ -t :nox
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y build-essential pkg-config automake cmake git libtool zlib1g-dev libssl-dev libgeoip-dev \
        libboost-dev libboost-system-dev libboost-random-dev \
    && apt install -y python3 \
    && apt install -y qtbase5-dev qtbase5-private-dev qttools5-dev libqt5svg5-dev

RUN apt install -y curl tree vim \
    && apt clean && rm -rf /var/lib/opt/lists/* /tmp/* /var/tmp/*

# build libtorrent-rasterbar 1.2.9
RUN mkdir -p /qbt
WORKDIR /qbt
RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git \
    && cd /qbt/libtorrent \
    && git checkout v1.2.19 \
    && cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build \
    && cmake --install build

RUN mkdir -p /qbt/github
COPY ./ /qbt/github
WORKDIR /qbt/github
RUN ./configure --disable-gui --prefix=/usr
RUN make -j$(nproc) && make install

EXPOSE 8089

ONBUILD WORKDIR /qbt
ONBUILD RUN rm -rf github
ONBUILD RUN rm -rf libtorrent
