FROM ubuntu:kinetic-20220830 AS build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y \
    autoconf \
    automake \
    curl \
    unzip \
    bison \
    flex \
    gcc \
    g++ \
    git \
    libprotobuf-dev \
    libnl-route-3-dev \
    libtool \
    make \
    pkg-config \
    protobuf-compiler

RUN git clone https://github.com/google/nsjail.git /nsjail && cd /nsjail && make

FROM ubuntu:kinetic-20220830
RUN apt-get update && \
    apt-get install -y libprotobuf-dev libnl-route-3-200 protobuf-compiler && \
    rm -rf /var/lib/apt/lists/

RUN export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get -y install -o APT::Immediate-Configure=false libc6:i386 libncurses5:i386 libstdc++6:i386

COPY --from=build /nsjail/nsjail /usr/bin/nsjail

RUN useradd -r -u 1000 ctf
COPY nsjail-pwn.sh /home/ctf/
RUN chmod +x /home/ctf/nsjail-pwn.sh

# run default script
ENTRYPOINT ["/bin/bash","/home/ctf/nsjail-pwn.sh"]
#ENTRYPOINT ["/bin/bash"]