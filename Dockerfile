FROM debian:10-slim as builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
    python3 \
    libopenblas-dev \
    ninja-build \
    protobuf-compiler \
    libprotobuf-dev \
    python3-pip \
    libopenblas-base \
    zlib1g-dev \
    ocl-icd-libopencl1 \
    tzdata \
    wget \
    git \
    python3-venv && \

    wget -O /root/mklml_lnx_2019.0.5.20190502.tgz "https://github.com/intel/mkl-dnn/releases/download/v0.20/mklml_lnx_2019.0.5.20190502.tgz" && \
    cd /root && tar xzf mklml_lnx_2019.0.5.20190502.tgz && \
    mkdir -p /opt/intel/mkl && \
    mv /root/mklml_lnx_2019.0.5.20190502/lib/libmklml_gnu.so /root/mklml_lnx_2019.0.5.20190502/lib/libmklml.so && \
    rm -f /root/mklml_lnx_2019.0.5.20190502/lib/libiomp5.so /root/mklml_lnx_2019.0.5.20190502/lib/libmklml_intel.so && \
    ln -s /root/mklml_lnx_2019.0.5.20190502/lib /opt/intel/mkl/lib && \
    ln -s /root/mklml_lnx_2019.0.5.20190502/include /opt/intel/mkl/include && \
# build LC0
    PATH="/$HOME/.local/bin:$PATH" && \
    git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    #git checkout $(git tag --list |grep -v rc |tail -1) && \
    #git checkout $(git tag --list |tail -1) && \
    git checkout 69105b4 && \
    pip3 install virtualenv --user && \
    pip3 install meson --user && \
        ln -s /usr/bin/python3 /usr/bin/python && \
    INSTALL_PREFIX=/root/.local ./build.sh -Dmkl_include="/opt/intel/mkl/include" -Dmkl_libdirs="/opt/intel/mkl/lib" -Db_lto=true -Ddefault_library=static >> /root/log-`date +%s`

FROM debian:10-slim

#ARG WORK_FILE='https://cdn.discordapp.com/attachments/530486338236055583/587323650282225700/LD2.pb.gz'
ARG TZ='America/Los_Angeles'

WORKDIR /root

COPY --from=builder /opt/intel/mkl/lib /opt/intel/mkl/lib
COPY --from=builder /root/lc0/build/release /root/lc0
COPY lc0cpu.sh /root

RUN echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y \
    tzdata \
    wget \
    libgomp1 \
    libprotobuf17 && \
#    wget $WORK_FILE && \
    apt purge wget git -y && \
    apt autoclean


ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

#ENTRYPOINT [ "/root/lc0cpu.sh" ]

CMD [ "/root/lc0cpu.sh" ]

