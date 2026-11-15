ARG DEBIAN_VERSION=bullseye-slim
FROM debian:${DEBIAN_VERSION} AS cross-grpc

ARG GNU_HOST=arm-linux-gnueabihf
ENV GNU_HOST=${GNU_HOST}

RUN if grep -qE "bullseye|buster" /etc/os-release 2>/dev/null; then \
      sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
      sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
      echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive; \
    fi && \
  apt-get update && \
  apt-get --no-install-recommends install -y \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    gcc-$GNU_HOST \
    g++-$GNU_HOST \
    git \
    gnupg \
    libc6-dev-armhf-cross \
    libc6-dev-arm64-cross \
    libssl-dev \
    libtool \
    pkg-config \
    software-properties-common \
    wget && \
  rm -rf /var/lib/apt/lists/*

ENV C_COMPILER_ARM_LINUX=$GNU_HOST-gcc
ENV CXX_COMPILER_ARM_LINUX=$GNU_HOST-g++

ENV CROSS_TOOLCHAIN=/usr/$GNU_HOST
ENV CROSS_STAGING_PREFIX=$CROSS_TOOLCHAIN/stage
ENV CMAKE_CROSS_TOOLCHAIN=/usr/local/share/cmake/arm.toolchain.cmake

COPY ./arm.toolchain.cmake /usr/local/share/cmake/arm.toolchain.cmake

ARG GRPC_VERSION=v1.37.1
ENV GRPC_VERSION=${GRPC_VERSION}

# https://github.com/grpc/grpc/blob/master/test/distrib/cpp/run_distrib_test_cmake_aarch64_cross.sh
RUN GRPC_DIR=/grpc && \
  git clone --depth 1 --branch $GRPC_VERSION --recursive --shallow-submodules https://github.com/grpc/grpc.git $GRPC_DIR && \
  # gRPC on the host
  GRPC_BUILD_DIR=$GRPC_DIR/cmake/build && \
  mkdir -p $GRPC_BUILD_DIR && \
  cd $GRPC_BUILD_DIR && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -DgRPC_SSL_PROVIDER=package \
    ../.. && \
  make -j`nproc` install && \
  # Abseil on the host
  ABSEIL_BUILD_DIR=$GRPC_DIR/third_party/abseil-cpp/cmake/build && \
  mkdir -p $ABSEIL_BUILD_DIR && \
  cd $ABSEIL_BUILD_DIR && \
  cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
    ../.. && \
  make -j`nproc` install && \
  # gRPC cross
  GRPC_CROSS_BUILD_DIR=$GRPC_DIR/cmake/cross_build && \
  mkdir -p $GRPC_CROSS_BUILD_DIR && \
  cd $GRPC_CROSS_BUILD_DIR && \
  cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_CROSS_TOOLCHAIN \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$CROSS_STAGING_PREFIX \
    ../.. && \
  make -j`nproc` install && \
  # Abseil cross
  ABSEIL_BUILD_DIR=$GRPC_DIR/third_party/abseil-cpp/cmake/build_cross && \
  mkdir -p $ABSEIL_BUILD_DIR && \
  cd $ABSEIL_BUILD_DIR && \
  cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_CROSS_TOOLCHAIN \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$CROSS_STAGING_PREFIX \
    -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
    ../.. && \
  make -j$(nproc) install && \
  cd / && \
  rm -rf $GRPC_DIR

FROM cross-grpc AS builder

WORKDIR /code

COPY ./src/. .

ENV BIN_DIR=/tmp/bin
ENV BUILD_DIR=./build

RUN mkdir -p $BIN_DIR && \
  mkdir -p $BUILD_DIR && \
  cd ./$BUILD_DIR && \
  cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_CROSS_TOOLCHAIN \
    -DCMAKE_BUILD_TYPE=Release \
    -DProtobuf_DIR=$CROSS_STAGING_PREFIX/lib/cmake/protobuf \
    -DgRPC_DIR=$CROSS_STAGING_PREFIX/lib/cmake/grpc \
    .. && \
  make -j`nproc` && \
  cp ./hello_* $BIN_DIR/

FROM scratch
COPY --from=builder /tmp/bin /
