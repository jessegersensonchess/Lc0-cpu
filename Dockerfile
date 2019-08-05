FROM ubuntu:18.04

COPY build-lc0-cpu.sh /root
COPY lc0cpu.sh /root
WORKDIR /root
RUN chmod +x /root/build-lc0-cpu.sh && chmod +x /root/lc0cpu.sh && DEBIAN_FRONTEND=noninteractive && /root/build-lc0-cpu.sh

ENTRYPOINT [ "/root/lc0cpu.sh" ]