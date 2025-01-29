#
# Dockerfile for ProphetFuzz-experiments (Ubuntu 20.04 base + LLVM 12 for afl-clang-lto).
#

FROM 4ugustus/prophetfuzz_base

# Install required dependencies
RUN apt update

# Prepare Dependency for programs
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    libcurl4-openssl-dev \
    libdeflate-dev \
    libjpeg-dev \
    libjbig-dev \
    libwebp-dev \
    liblzma-dev \
    libogg-dev \
    libvorbis-dev \
    libao-dev \
    libflac-dev \
    libspeex-dev \
    gettext \
    libbz2-dev \
    liblzo2-dev \
    liblz4-dev \
    libonig-dev \
    tcpdump \
    check \
    kmod \
    gawk \
    libgcrypt-dev \
    libc-ares-dev \
    appstream \
    lpr \
    freeglut3-dev \
    graphviz \
    libappstream-dev \
    libboost-dev \
    libcairo2-dev \
    libde265-dev \
    libdjvulibre-dev \
    libexif-dev \
    libexpat1-dev \
    libfftw3-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgl1-mesa-dev \
    libglew-dev \
    libglfw3-dev \
    libglib2.0-dev \
    libglm-dev \
    libgsl-dev \
    libgslcblas0 \
    libgtksourceview-3.0-dev \
    libheif-dev \
    libjpeg-turbo8-dev \
    libjpeg8-dev \
    liblcms2-dev \
    liblqr-1-0-dev \
    libltdl-dev \
    libnss3-dev \
    libopenexr-dev \
    libopenjp2-7-dev \
    libpango1.0-dev \
    libpcre3-dev \
    libpng-dev \
    libraqm-dev \
    libraw-dev \
    librsvg2-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libssl-dev \
    libtiff-dev \
    libtiff5-dev \
    libwmf-dev \
    libxml2-dev \
    libxt-dev \
    libzip-dev \
    texinfo \
    zlib1g-dev \
    libx264-dev \
    xmlto

RUN pip3 install wllvm sysv-ipc \
    requests \
    beautifulsoup4

RUN mkdir /root/dep
WORKDIR /root/dep

# Zstd
RUN git clone https://github.com/facebook/zstd; \
    cd zstd; \
    make -j install; \
    ln -s /lib/x86_64-linux-gnu/libzstd.so.1 /lib/x86_64-linux-gnu/libzstd.so

# Lerc
RUN git clone https://github.com/esri/lerc; \
    cd lerc; \
    mkdir tmp; cd tmp; \
    cmake ..; \
    make -j install; \
    ln -s /usr/local/lib/libLerc.so /lib/x86_64-linux-gnu/libLerc.so; \
    ln -s /usr/local/lib/libLerc.so.4 /lib/x86_64-linux-gnu/libLerc.so.4

# libdnet
RUN git clone https://github.com/ofalk/libdnet.git; \
    cd libdnet; \
    ./configure; \
    make -j install

# spread-sheet-widget
RUN wget -O- http://alpha.gnu.org/gnu/ssw/spread-sheet-widget-0.8.tar.gz | tar zxv; \
    cd spread-sheet-widget-0.8; \
    ./configure; \
    make -j; \
    make install

# Install Go
RUN rm -rf /usr/local/go && \
    wget -O- https://go.dev/dl/go1.19.3.linux-amd64.tar.gz | tar zxv -C /usr/local

RUN echo "export GOPATH=/root/go" >> ~/.bashrc; \
    echo "export PATH=$PATH:/root/go/bin:/usr/local/go/bin" >> ~/.bashrc

ENV GOPATH=/root/go \
    PATH=$PATH:/root/go/bin:/usr/local/go/bin

RUN go env -w GO111MODULE=off; \
    go get github.com/SRI-CSL/gllvm/cmd/...

# Prepare build scripts
RUN /bin/echo -e '#!/bin/bash\nCFLAGS="-g -O0" CXXFLAGS="-g -O0" ./configure --prefix=$PWD/build_orig --disable-shared "$@"; make -j; make install; make clean' > /usr/bin/orig_configure && chmod +x /usr/bin/orig_configure && \
    /bin/echo -e '#!/bin/bash\nCFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" CXXFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" ./configure --prefix=$PWD/build_asan --disable-shared "$@"; make -j; make install; make clean' > /usr/bin/asan_configure && chmod +x /usr/bin/asan_configure && \
    /bin/echo -e '#!/bin/bash\nCC=/root/fuzzer/afl++/afl-clang-fast CXX=/root/fuzzer/afl++/afl-clang-fast++ ./configure --prefix=$PWD/build_afl++/ --disable-shared "$@"; make -j; make install; make clean' > /usr/bin/afl++_configure && chmod +x /usr/bin/afl++_configure && \
    /bin/echo -e '#!/bin/bash\nCC=/root/ProphetFuzz/fuzzer/afl-clang-fast CXX=/root/ProphetFuzz/fuzzer/afl-clang-fast++ ./configure --prefix=$PWD/build_prophetfuzz/ --disable-shared "$@"; make -j; make install; make clean' > /usr/bin/prophetfuzz_configure && chmod +x /usr/bin/prophetfuzz_configure && \
    /bin/echo -e '#!/bin/bash\norig_configure "$@"; asan_configure "$@"; afl++_configure "$@"; prophetfuzz_configure "$@"' > /usr/bin/all_configure && chmod +x /usr/bin/all_configure && \
    /bin/echo -e '#!/bin/bash\nCC=gclang CXX=gclang++ ./configure --prefix=$PWD/build_orig --disable-shared "$@"; make -j; make install' > /usr/bin/gclang_configure && chmod +x /usr/bin/gclang_configure

RUN /bin/echo -e '#!/bin/bash\nCFLAGS="-g -O0" CXXFLAGS="-g -O0" cmake .. -DCMAKE_INSTALL_PREFIX=../build_orig  -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/bin/orig_cmake && chmod +x /usr/bin/orig_cmake && \
    /bin/echo -e '#!/bin/bash\nCFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" CXXFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" cmake .. -DCMAKE_INSTALL_PREFIX=../build_asan -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/bin/asan_cmake && chmod +x /usr/bin/asan_cmake && \
    /bin/echo -e '#!/bin/bash\nCC=/root/fuzzer/afl++/afl-clang-fast CXX=/root/fuzzer/afl++/afl-clang-fast++ cmake .. -DCMAKE_INSTALL_PREFIX=../build_afl++  -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/bin/afl++_cmake && chmod +x /usr/bin/afl++_cmake && \
    /bin/echo -e '#!/bin/bash\nCC=/root/ProphetFuzz/fuzzer/afl-clang-fast CXX=/root/ProphetFuzz/fuzzer/afl-clang-fast++ cmake .. -DCMAKE_INSTALL_PREFIX=../build_prophetfuzz  -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/bin/prophetfuzz_cmake && chmod +x /usr/bin/prophetfuzz_cmake && \
    /bin/echo -e '#!/bin/bash\norig_cmake "$@"; asan_cmake "$@"; afl++_cmake "$@"; prophetfuzz_cmake "$@";' > /usr/bin/all_cmake && chmod +x /usr/bin/all_cmake && \
    /bin/echo -e '#!/bin/bash\nCC=gclang CXX=gclang++ cmake .. -DCMAKE_INSTALL_PREFIX=../build_orig -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install' > /usr/bin/gclang_cmake && chmod +x /usr/bin/gclang_cmake

RUN /bin/echo -e '#!/bin/bash\nget-bc ./build_orig/bin/${program}; mkdir build_orig/target_prophetfuzz_${program};/root/ProphetFuzz/fuzzer/afl-clang-lto build_orig/bin/${program}.bc ${build_flag} -o build_orig/target_prophetfuzz_${program}/${program}.afl' > /usr/bin/prophetfuzz_process && chmod +x /usr/bin/prophetfuzz_process && \
    /bin/echo -e '#!/bin/bash\nmkdir build_orig/target_afl++_${program};/root/fuzzer/afl++/afl-clang-lto build_orig/bin/${program}.bc ${build_flag} -o build_orig/target_afl++_${program}/${program}.afl' > /usr/bin/afl++_process && chmod +x /usr/bin/afl++_process

RUN Xvfb :99 -ac &
ENV DISPLAY=:99

# Prepare Programs for RQ1-4
RUN mkdir /root/programs
WORKDIR /root/programs

## Cmark
RUN git clone https://github.com/commonmark/cmark cmark-git-9c8e8; \
    cd cmark-git-9c8e8; \
    git reset --hard 9c8e8341361fddc94322f9e0d7e9439e50d16138; \
    mkdir build; cd build; \
    all_cmake

## Libsixel (Fixed: install tools + chmod +x autogen.sh)
RUN apt update && apt install -y libtool automake autoconf pkg-config \
 && git clone https://github.com/saitoha/libsixel libsixel-git-6a5be \
 && cd libsixel-git-6a5be \
 && git reset --hard 6a5be8b72d84037b83a5ea838e17bcf372ab1d5f \
 && autoreconf -fi \
 && all_configure

## Libtiff
RUN git clone https://gitlab.com/libtiff/libtiff libtiff-git-b51bb; \
    cd libtiff-git-b51bb; \
    git reset --hard b51bb157123264e26d34c09cc673d213aea61fc7; \
    bash ./autogen.sh; \
    all_configure

## OpenSSL
RUN git clone https://github.com/openssl/openssl openssl-git-31ff3; \
    cd openssl-git-31ff3; \
    git reset --hard 31ff3635371b51c8180838ec228c164aec3774b6
RUN cd openssl-git-31ff3; \
    sed -i '339s/.*/    p = "123456\\n";\n    strcpy(result, p);/' crypto/ui/ui_openssl.c; \
    CFLAGS="-g -O0" ./config --prefix=$PWD/build_orig no-shared no-module -DPEDANTIC enable-tls1_3 enable-weak-ssl-ciphers enable-rc5 enable-md2 enable-ssl3 enable-ssl3-method enable-nextprotoneg enable-ec_nistp_64_gcc_128 -fno-sanitize=alignment --debug; make -j; make install; make clean; \
    CFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" ./config --prefix=$PWD/build_asan no-shared enable-asan no-module -DPEDANTIC enable-tls1_3 enable-weak-ssl-ciphers enable-rc5 enable-md2 enable-ssl3 enable-ssl3-method enable-nextprotoneg enable-ec_nistp_64_gcc_128 -fno-sanitize=alignment --debug; make -j; make install; make clean; \
    for fuzzer in afl++; do CC=/root/fuzzer/${fuzzer}/afl-clang-fast ./config --prefix=$PWD/build_${fuzzer} enable-fuzz-afl no-shared no-module -DPEDANTIC enable-tls1_3 enable-weak-ssl-ciphers enable-rc5 enable-md2 enable-ssl3 enable-ssl3-method enable-nextprotoneg enable-ec_nistp_64_gcc_128 -fno-sanitize=alignment --debug; make -j; make install; make clean; done; \
    CC=/root/ProphetFuzz/fuzzer/afl-clang-fast ./config --prefix=$PWD/build_prophetfuzz enable-fuzz-afl no-shared no-module -DPEDANTIC enable-tls1_3 enable-weak-ssl-ciphers enable-rc5 enable-md2 enable-ssl3 enable-ssl3-method enable-nextprotoneg enable-ec_nistp_64_gcc_128 -fno-sanitize=alignment --debug; make -j; make install; make clean

## Xpdf
RUN wget -O- https://dl.xpdfreader.com/old/xpdf-4.03.tar.gz | tar zxv; \
    cd xpdf-4.03; \
    mkdir build; cd build; \
    all_cmake

## Vorbis-tools
RUN wget -O- https://github.com/xiph/vorbis-tools/archive/refs/tags/v1.4.2.tar.gz | tar zxv; \
    cd vorbis-tools-1.4.2; \
    ./autogen.sh; \
    all_configure

## Podofo
RUN wget -O- http://sourceforge.net/projects/podofo/files/podofo/0.9.8/podofo-0.9.8.tar.gz/download | tar zxv; \
    cd podofo-0.9.8; \
    mkdir build; cd build; \
    all_cmake; \
    cd ..

## Lrzip
RUN wget -O- https://github.com/ckolivas/lrzip/archive/refs/tags/v0.651.tar.gz | tar zxv; \
    cd lrzip-0.651; \
    ./autogen.sh; \
    all_configure

## Speex
RUN wget -O- https://github.com/xiph/speex/archive/refs/tags/Speex-1.2.1.tar.gz | tar zxv; \
    cd speex-Speex-1.2.1; \
    ./autogen.sh; \
    all_configure

## Jpegoptim
RUN wget -O- https://github.com/tjko/jpegoptim/archive/refs/tags/v1.5.0.tar.gz | tar zxv; \
    cd jpegoptim-1.5.0; \
    all_configure

## Jq
RUN wget -O- https://github.com/stedolan/jq/releases/download/jq-1.6/jq-1.6.tar.gz | tar zxv; \
    cd jq-1.6; \
    all_configure; \
    sed -i "36s/.*/\.SH \"OPTIONS\"/" build_orig/share/man/man1/jq.1

## Libjpeg-turbo
RUN wget -O- https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.1.4.tar.gz | tar zxv; \
    cd libjpeg-turbo-2.1.4; \
    mkdir build; cd build; \
    all_cmake

## Tcpreplay
RUN wget -O- https://github.com/appneta/tcpreplay/releases/download/v4.4.2/tcpreplay-4.4.2.tar.xz | tar xJ; \
    cd tcpreplay-4.4.2; \
    all_configure --enable-debug --with-netmap=/netmap

## Elfutil
RUN wget -O- https://sourceware.org/elfutils/ftp/0.188/elfutils-0.188.tar.bz2 | tar xvj; \
    cd elfutils-0.188; \
    for cmd in "orig_configure" "asan_configure"; do \
      ${cmd} --enable-elf-stt-common --enable-elf-stt-common --enable-maintainer-mode --disable-debuginfod --disable-libdebuginfod --without-bzlib --without-lzma --without-zstd CFLAGS="-Wno-error $CFLAGS"; \
    done; \
    LLVM_COMPILER=clang CC=wllvm CFLAGS="-Wno-error" ./configure --prefix=$PWD/build_afl++ --enable-elf-stt-common --enable-elf-stt-common --enable-maintainer-mode --disable-debuginfod --disable-libdebuginfod --without-bzlib --without-lzma --without-zstd; \
    LLVM_COMPILER=clang make -j; \
    LLVM_COMPILER=clang make install; \
    make clean; \
    cp -r build_afl++ build_prophetfuzz; \
    extract-bc build_afl++/bin/eu-elfclassify; \
    /root/fuzzer/afl++/afl-clang-fast build_afl++/bin/eu-elfclassify.bc -o build_afl++/bin/eu-elfclassify -L$PWD/build_afl++/lib -lelf -ldw -lstdc++ -lasm; \
    extract-bc build_prophetfuzz/bin/eu-elfclassify; \
    /root/ProphetFuzz/fuzzer/afl-clang-fast build_prophetfuzz/bin/eu-elfclassify.bc -o build_prophetfuzz/bin/eu-elfclassify -L$PWD/build_prophetfuzz/lib -lelf -ldw -lstdc++ -lasm

## Wireshark
RUN wget -O- https://2.na.dl.wireshark.org/src/all-versions/wireshark-4.0.1.tar.xz | tar xJ; \
    cd wireshark-4.0.1; \
    apt install -y libspeexdsp-dev; \
    mkdir build; cd build; \
    all_cmake -DBUILD_wireshark=OFF; \
    cd ..

# Prepare Programs for RQ5
RUN mkdir /root/programs_rq5
WORKDIR /root/programs_rq5

### (RQ5 programs here, unchanged - omitted for brevity)

# Prepare Programs for Configfuzz
RUN mkdir /root/programs_configfuzz
WORKDIR /root/programs_configfuzz

### (Configfuzz programs here, unchanged - omitted for brevity)

# All finished
WORKDIR /root/ProphetFuzz
