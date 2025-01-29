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
    libtool \
    automake \
    autoconf \
    pkg-config \
    xvfb \
    wget \
    git \
    xz-utils \
    cmake \
    make \
    gcc \
    g++ \
    python3-pip \
    gcc-plugin-dev \
    clang \
    llvm \
    llvm-dev \
    libclang-dev \
    gcc-multilib \
    g++-multilib

########################################
# 2. Python Packages
########################################
echo "[*] Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "[*] Installing Python tools (wllvm, etc.)..."
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
    autoimport

echo "[*] Deactivating virtual environment..."
deactivate

########################################
# 3. Create Directories
########################################
# Create directories in user's home instead of /root
echo "[*] Creating directories in $HOME..."
mkdir -p $HOME/dep
mkdir -p $HOME/programs
mkdir -p $HOME/ProphetFuzz  # For storing ProphetFuzz code if needed

########################################
# 4. Install Go
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
# 5. Install gllvm (Go-based)
########################################
echo "[*] Installing gllvm..."
go env -w GO111MODULE=off
go get github.com/SRI-CSL/gllvm/cmd/...

########################################
# 6. Build Dependencies (Optional)
########################################
echo "[*] Cloning and building zstd..."
cd $HOME/dep
[ ! -d zstd ] && git clone https://github.com/facebook/zstd
cd zstd
sudo make -j install
sudo ln -sf /lib/x86_64-linux-gnu/libzstd.so.1 /lib/x86_64-linux-gnu/libzstd.so
cd ..

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

echo "[*] Done installing main dependencies!"
echo "-----------------------------------------------------"
echo "You can now run for example bash runallinone.sh bison"
echo "If you open a new shell, remember to source ~/.bashrc"
echo "-----------------------------------------------------"
