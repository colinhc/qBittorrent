# docker build ./ -t :nox
FROM ubuntu:23.04

ENV DEBIAN_FRONTEND=noninteractive

# https://github.com/qbittorrent/qBittorrent/wiki/Compilation:-Debian,-Ubuntu,-and-derivatives
RUN apt update \
    && apt install -y build-essential cmake git ninja-build pkg-config \
         libboost-dev libssl-dev zlib1g-dev libgl1-mesa-dev \
    && apt install -y qtbase5-dev qttools5-dev libqt5svg5-dev

RUN apt install -y curl tree vim \
    && apt clean && rm -rf /var/lib/opt/lists/* /tmp/* /var/tmp/*

# release-4.6.0alpha1 requires v1.2.19.
RUN mkdir -p /qbt/libtorrent
WORKDIR /qbt/libtorrent
RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git \
    && cd libtorrent \
    && git checkout v1.2.19 \
    && cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build \
    && cmake --install build

RUN mkdir -p /qbt/github
COPY ./ /qbt/github
WORKDIR /qbt/github
RUN ./configure CXXFLAGS="-std=c++14" --disable-gui --prefix=/usr
RUN make -j$(nproc) && make install

EXPOSE 8089

ONBUILD WORKDIR /qbt
ONBUILD RUN rm -rf github
ONBUILD RUN rm -rf libtorrent
