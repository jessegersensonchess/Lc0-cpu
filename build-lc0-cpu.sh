#!/bin/bash

cd /root
echo "America/Los_Angeles" > /etc/timezone    
#dpkg-reconfigure -f noninteractive tzdata

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3 libopenblas-dev ninja-build protobuf-compiler libprotobuf-dev python3-pip libopenblas-base libprotobuf10 zlib1g-dev ocl-icd-libopencl1 tzdata wget supervisor git python3-venv

wget https://github.com/intel/mkl-dnn/releases/download/v0.20/mklml_lnx_2019.0.5.20190502.tgz
tar xzf mklml_lnx_2019.0.5.20190502.tgz
mkdir /opt/intel
mkdir /opt/intel/mkl
ln -s /root/mklml_lnx_2019.0.5.20190502/lib /opt/intel/mkl/lib
ln -s /root/mklml_lnx_2019.0.5.20190502/include /opt/intel/mkl/include
cp /opt/intel/mkl/lib/libmklml_gnu.so /opt/intel/mkl/lib/libmklml.so

#### BUILD LC0 ####
PATH="/$HOME/.local/bin:$PATH"
git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git
cd /root/lc0
git checkout $(git tag --list |grep -v rc |tail -1)
pip3 install virtualenv --user
pip3 install meson --user
INSTALL_PREFIX=/root/.local ./build.sh -Dmkl_include="/opt/intel/mkl/include" -Dmkl_libdirs="/opt/intel/mkl/lib" -Db_lto=true -Ddefault_library=static >> /root/log-`date +%s`
cd /root
wget "https://cdn.discordapp.com/attachments/530486338236055583/587323650282225700/LD2.pb.gz"

