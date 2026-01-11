FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential cmake git ninja-build pkg-config libboost-dev \
    libssl-dev zlib1g-dev libgl1-mesa-dev \
    python3

RUN apt install -y --no-install-recommends \
    qt6-base-dev qt6-base-private-dev qt6-tools-dev qt6-svg-dev

RUN apt install -y curl tree vim \
    && apt clean && rm -rf /var/lib/opt/lists/* /tmp/* /var/tmp/*

# build libtorrent-rasterbar 1.2.9
RUN mkdir -p /qbt
WORKDIR /qbt
RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git \
    && cd /qbt/libtorrent \
    && git checkout RC_2_0 \
    && cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build \
    && cmake --install build

RUN mkdir -p /qbt/github
COPY ./ /qbt/github
WORKDIR /qbt/github
RUN cmake -G "Ninja" -B build \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DGUI=OFF \
    -DMSVC_RUNTIME_DYNAMIC=OFF
RUN cmake --build build --parallel $(nproc) \
    # install qbittorrent-nox to /usr/local/bin
    && cmake --install build

EXPOSE 8089

ONBUILD WORKDIR /qbt
ONBUILD RUN rm -rf github
ONBUILD RUN rm -rf libtorrent
