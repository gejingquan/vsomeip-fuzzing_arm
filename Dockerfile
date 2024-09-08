# Use AFLplusplus as the base image
FROM aflplusplus/aflplusplus:latest

# Set environment variable
ENV TERM=xterm-256color

# Install necessary packages
RUN apt-get update && \
    apt-get install -y gcc-arm-linux-gnueabihf libncurses-dev pkg-config u-boot-tools device-tree-compiler g++-arm-linux-gnueabihf gcc-arm-none-eabi

# Set up QEMU mode with AFL++
WORKDIR /AFLplusplus/qemu_mode
RUN NO_CHECKOUT=1 CPU_TARGET=arm STATIC=1 ./build_qemu_support.sh && \
    cd /AFLplusplus && \
    make install

# Download and install Boost libraries
WORKDIR /
RUN wget https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.gz && \
    tar -xzf boost_1_74_0.tar.gz && \
    cd boost_1_74_0 && \
    ./bootstrap.sh && \
    rm -rf project-config.jam && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/boost/project-config.jam && \
    ./b2 abi=aapcs toolset=gcc-arm install --prefix=./install -j 64

# Clone and build vSomeIP with custom CMake configurations
WORKDIR /
RUN git clone https://github.com/COVESA/vsomeip && \
    cd vsomeip && \
    rm -rf CMakeLists.txt && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/vsomeip/CMakeLists.txt && \
    mkdir build && \
    cd build && \
    CC=/usr/bin/arm-linux-gnueabihf-gcc CXX=/usr/bin/arm-linux-gnueabihf-g++ cmake -DENABLE_SIGNAL_HANDLING=1 -DENABLE_MULTIPLE_ROUTING_MANAGERS=1 -DBOOST_ROOT=/boost_1_74_0/build -DBoost_INCLUDE_DIR=/boost_1_74_0/build/include/boost -DBoost_LIBRARY_DIR=/boost_1_74_0/lib /vsomeip && \
    make -j64

# Prepare the fuzzing environment
WORKDIR /
RUN mkdir fuzzing && \
    cd fuzzing && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/src/fuzzing.cpp && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/src/fuzzing.hpp && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/CMakeLists.txt && \
    mkdir build && \
    cd build && \
    CC=/usr/bin/arm-linux-gnueabihf-gcc CXX=/usr/bin/arm-linux-gnueabihf-g++ cmake -D USE_GCC=ON /fuzzing && \
    make -j64

# Copy necessary binaries and libraries for fuzzing
WORKDIR /
RUN mkdir fuzz && \
    cd fuzz && \    
    mkdir tmp && \
    mkdir lib && \
    cp /fuzzing/build/fuzzing ./ && \
    cp /AFLplusplus/qemu_mode/qemuafl/build/arm-linux-user/qemu-arm ./ && \
    cp /vsomeip/build/* /fuzz/lib/ && \
    cp /boost_1_74_0/install/lib/* /fuzz/lib/ && \
    cp /usr/arm-linux-gnueabihf/lib/* /lib/

# Setup input and output directories for AFL
RUN mkdir output && \
    mkdir input && \
    cd input && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_arm/main/input/vsomeip.json

# Set default work directory
WORKDIR /fuzz
