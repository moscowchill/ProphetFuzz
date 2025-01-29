#!/usr/bin/env bash
#
# install_deps.sh
#
# Installs ProphetFuzz dependencies on a local Ubuntu 20.04 system
# without using Docker. Adapt as necessary for your setup.
#

set -e  # Exit on error

########################################
# 1. System Packages
########################################
echo "[*] Updating and installing system dependencies..."
sudo apt-get update

# Many of these come from the Dockerfile lines:
#   RUN DEBIAN_FRONTEND=noninteractive apt install -y ...
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python3-dev \
    python3-pip \
    python3-setuptools \
    automake \
    cmake \
    git \
    libtool \
    screen \
    jq \
    lsb-release \
    xvfb \
    libpcap-dev \
    libspeexdsp-dev \
    flex \
    libpixman-1-dev \
    cargo \
    asciidoctor \
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
    xmlto \
    ffmpeg \
    lrzip \
    iputils-ping \
    tcpdump \
    binutils \
    gpac \
    speex \
    imagemagick \
    tshark \
    wireshark-common \
    sudo \
    netcat \
    nasm \
    exiv2 \
    libsixel-bin \
    lrzip \
    lame \
    binutils-arm-linux-gnueabi \
    vorbis-tools \
    opus-tools \
    sox \
    openssl \
    xxd \
    libtiff-tools \
    netpbm \
    yara \
    pkg-config \
    autoconf \
    wget \
    curl \
    gnupg

########################################
# 1.1 Install LLVM and Clang 12
########################################
echo "[*] Installing LLVM and Clang 12..."
# Add LLVM repository
echo "deb http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-get update

# Install LLVM/Clang packages
sudo apt-get install -y \
    clang-12 \
    clang-tools-12 \
    libc++1-12 \
    libc++-12-dev \
    libc++abi1-12 \
    libc++abi-12-dev \
    libclang1-12 \
    libclang-12-dev \
    libclang-common-12-dev \
    libclang-cpp12 \
    libclang-cpp12-dev \
    liblld-12 \
    liblld-12-dev \
    liblldb-12 \
    liblldb-12-dev \
    libllvm12 \
    lld-12 \
    lldb-12 \
    llvm-12 \
    llvm-12-dev \
    llvm-12-runtime \
    llvm-12-tools

# Install GCC plugin development files
sudo apt-get install -y \
    gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev \
    libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev \
    gcc-multilib \
    g++-multilib

# Set up alternatives for LLVM/Clang tools
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 100
sudo update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-12 100
sudo update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-12 100
sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-12 100
sudo update-alternatives --install /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-12 100
sudo update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-12 100

########################################
# 2. Python Packages
########################################
echo "[*] Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "[*] Installing Python tools and dependencies..."
pip install --no-cache-dir \
    wllvm \
    sysv_ipc \
    requests \
    beautifulsoup4 \
    demjson3 \
    tqdm \
    isort \
    python-dotenv \
    networkx \
    autoimport \
    opencv-python \
    Pillow \
    scapy \
    lxml \
    numpy \
    wave \
    pydub \
    fpdf \
    cryptography \
    reportlab \
    pyreadstat \
    pandas \
    matplotlib \
    datetime \
    PyPDF2 \
    moviepy \
    pyelftools \
    pyshark \
    pypcap \
    piexif \
    cairosvg \
    pytest-shutil \
    tinytag \
    pycryptodomex \
    pathlib \
    dpkt \
    pycryptodome \
    pyopenssl \
    pyasn1 \
    savReaderWriter \
    asn1tools \
    asn1

echo "[*] Deactivating virtual environment..."
deactivate

########################################
# 3. Create Directories and Setup Environment
########################################
echo "[*] Creating directories in $HOME..."
mkdir -p $HOME/dep
mkdir -p $HOME/programs
mkdir -p $HOME/programs_rq5
mkdir -p $HOME/programs_configfuzz
mkdir -p $HOME/ProphetFuzz
mkdir -p $HOME/fuzzer

########################################
# 4. Build Core Dependencies
########################################
echo "[*] Building core dependencies..."
cd $HOME/dep

# netmap
echo "[*] Building netmap..."
git clone https://github.com/luigirizzo/netmap
cd netmap
git reset --hard d67a604e805b67efb563ea8d5eb2d1318acf6ed8
cd LINUX
./configure
make -j
sudo make install
cd ../..

# libdnet
echo "[*] Building libdnet..."
git clone https://github.com/ofalk/libdnet.git
cd libdnet
./configure
make -j
sudo make install
cd ..

# spread-sheet-widget
echo "[*] Building spread-sheet-widget..."
wget -O- http://alpha.gnu.org/gnu/ssw/spread-sheet-widget-0.8.tar.gz | tar zxv
cd spread-sheet-widget-0.8
./configure
make -j
sudo make install
cd ..

# Lerc
echo "[*] Building Lerc..."
git clone https://github.com/esri/lerc
cd lerc
mkdir tmp && cd tmp
cmake ..
make -j install
sudo ln -s /usr/local/lib/libLerc.so /lib/x86_64-linux-gnu/libLerc.so
sudo ln -s /usr/local/lib/libLerc.so.4 /lib/x86_64-linux-gnu/libLerc.so.4
cd ../..

# zstd
echo "[*] Building zstd..."
[ ! -d zstd ] && git clone https://github.com/facebook/zstd
cd zstd
sudo make -j install
sudo ln -sf /lib/x86_64-linux-gnu/libzstd.so.1 /lib/x86_64-linux-gnu/libzstd.so
cd ..

# Create symlink for avconv
sudo ln -sf /usr/bin/ffmpeg /usr/bin/avconv

########################################
# 5. Install Go
########################################
echo "[*] Installing Go 1.19.3..."
cd /tmp
wget --quiet https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
rm go1.19.3.linux-amd64.tar.gz

# Make sure your PATH includes /usr/local/go/bin:
cat << 'EOF' >> ~/.bashrc

# Go environment for ProphetFuzz
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
EOF

# Apply changes to current shell
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

########################################
# 6. Install gllvm
########################################
echo "[*] Installing gllvm..."
go env -w GO111MODULE=off
go get github.com/SRI-CSL/gllvm/cmd/...

########################################
# 7. Install AFL++
########################################
echo "[*] Installing AFL++..."
cd $HOME
mkdir -p fuzzer
cd fuzzer
[ ! -d afl++ ] && git clone https://github.com/AFLplusplus/AFLplusplus afl++
cd afl++
make
sudo make install
cd ..

########################################
# 8. Set up Build Scripts
########################################
echo "[*] Setting up build scripts..."
# Configure scripts
echo '#!/bin/bash
CFLAGS="-g -O0" CXXFLAGS="-g -O0" ./configure --prefix=$PWD/build_orig --disable-shared "$@"; make -j; make install; make clean' > /usr/local/bin/orig_configure
chmod +x /usr/local/bin/orig_configure

echo '#!/bin/bash
CFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" CXXFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" ./configure --prefix=$PWD/build_asan --disable-shared "$@"; make -j; make install; make clean' > /usr/local/bin/asan_configure
chmod +x /usr/local/bin/asan_configure

echo '#!/bin/bash
CC=$HOME/fuzzer/afl++/afl-clang-fast CXX=$HOME/fuzzer/afl++/afl-clang-fast++ ./configure --prefix=$PWD/build_afl++/ --disable-shared "$@"; make -j; make install; make clean' > /usr/local/bin/afl++_configure
chmod +x /usr/local/bin/afl++_configure

echo '#!/bin/bash
CC=$HOME/ProphetFuzz/fuzzer/afl-clang-fast CXX=$HOME/ProphetFuzz/fuzzer/afl-clang-fast++ ./configure --prefix=$PWD/build_prophetfuzz/ --disable-shared "$@"; make -j; make install; make clean' > /usr/local/bin/prophetfuzz_configure
chmod +x /usr/local/bin/prophetfuzz_configure

echo '#!/bin/bash
orig_configure "$@"; asan_configure "$@"; afl++_configure "$@"; prophetfuzz_configure "$@"' > /usr/local/bin/all_configure
chmod +x /usr/local/bin/all_configure

# CMake scripts
echo '#!/bin/bash
CFLAGS="-g -O0" CXXFLAGS="-g -O0" cmake .. -DCMAKE_INSTALL_PREFIX=../build_orig -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/local/bin/orig_cmake
chmod +x /usr/local/bin/orig_cmake

echo '#!/bin/bash
CFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" CXXFLAGS="-g -fsanitize=address -fno-omit-frame-pointer" cmake .. -DCMAKE_INSTALL_PREFIX=../build_asan -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/local/bin/asan_cmake
chmod +x /usr/local/bin/asan_cmake

echo '#!/bin/bash
CC=$HOME/fuzzer/afl++/afl-clang-fast CXX=$HOME/fuzzer/afl++/afl-clang-fast++ cmake .. -DCMAKE_INSTALL_PREFIX=../build_afl++ -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/local/bin/afl++_cmake
chmod +x /usr/local/bin/afl++_cmake

echo '#!/bin/bash
CC=$HOME/ProphetFuzz/fuzzer/afl-clang-fast CXX=$HOME/ProphetFuzz/fuzzer/afl-clang-fast++ cmake .. -DCMAKE_INSTALL_PREFIX=../build_prophetfuzz -DBUILD_SHARED_LIBS:BOOL=OFF "$@"; make -j; make install; rm -rf ./*' > /usr/local/bin/prophetfuzz_cmake
chmod +x /usr/local/bin/prophetfuzz_cmake

echo '#!/bin/bash
orig_cmake "$@"; asan_cmake "$@"; afl++_cmake "$@"; prophetfuzz_cmake "$@"' > /usr/local/bin/all_cmake
chmod +x /usr/local/bin/all_cmake

# Processing scripts for ProphetFuzz
echo '#!/bin/bash
get-bc ./build_orig/bin/${program}; mkdir -p build_orig/target_prophetfuzz_${program};$HOME/ProphetFuzz/fuzzer/afl-clang-lto build_orig/bin/${program}.bc ${build_flag} -o build_orig/target_prophetfuzz_${program}/${program}.afl' > /usr/local/bin/prophetfuzz_process
chmod +x /usr/local/bin/prophetfuzz_process

echo '#!/bin/bash
mkdir -p build_orig/target_afl++_${program};$HOME/fuzzer/afl++/afl-clang-lto build_orig/bin/${program}.bc ${build_flag} -o build_orig/target_afl++_${program}/${program}.afl' > /usr/local/bin/afl++_process
chmod +x /usr/local/bin/afl++_process

echo "[*] All build scripts have been set up in /usr/local/bin"

echo "[*] Done installing main dependencies!"
echo "-----------------------------------------------------"
echo "You can now run for example bash runallinone.sh bison"
echo "If you open a new shell, remember to source ~/.bashrc"
echo "-----------------------------------------------------"
