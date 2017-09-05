FROM ubuntu:16.04

MAINTAINER lihe <liheemail@163.com>

#ARG http_proxy=http://192.168.3.3:1087
#ARG https_proxy=http://192.168.3.3:1087
ARG DEPENDENCE_PACKAGE="git unzip make python curl sed bzip2 pkg-config texinfo\
    zlib1g-dev:i386 libssl-dev:i386 libstdc++6:i386 libglib2.0-0:i386"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y $DEPENDENCE_PACKAGE \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd nacl && useradd -m -g nacl nacl

USER nacl

WORKDIR /home/nacl

ENV NACL_SDK_ROOT /home/nacl/nacl_sdk/pepper_49
ENV NACL_ARCH=pnacl TOOLCHAIN=pnacl
ENV PATH=/home/nacl/depot_tools:"$PATH"

RUN git config --global user.email "li.he@chinaott.net" \
    && git config --global user.name "lihe" \
#setup nacl_sdk
    && cd /home/nacl \
    && curl -O "https://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip" \
    && unzip nacl_sdk.zip \
    && cd nacl_sdk \
    && ./naclsdk list \
    && ./naclsdk update pepper_49 \
    && rm -rf ../nacl_sdk.zip \
#setup depot_tools
    && cd /home/nacl \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git \
#setup webports
    && cd /home/nacl \
    && mkdir webports \
    && cd webports \
    && gclient config --unmanaged --name=src https://chromium.googlesource.com/webports.git \
    && gclient sync --with_branch_heads \
    && cd src \
    && git checkout -b pepper_49 origin/pepper_49 \
    && gclient sync \
    && ls . \
#build webports
    && cd /home/nacl/webports/src \
    && sed -i  "/^TestStep/,/^}/s/^/#/g" ports/glibc-compat/build.sh \
    && sed -i  "/^TestStep/,/^}/s/^/#/g" ports/openssl/build.sh \
    && sed -i  "/^TestStep/,/^}/s/^/#/g" ports/zlib/build.sh \
    && sed -i  "/^TestStep/,/^}/s/^/#/g" ports/nacl-spawn/build.sh \
    && make curl

CMD ["/bin/bash"]
