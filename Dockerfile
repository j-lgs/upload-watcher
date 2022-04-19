FROM alpine:3.15.4

LABEL org.opencontainers.image.source https://github.com/j-lgs/upload-watcher

ENV SHNTOOL_VERSION=3.0.10
ENV TTAENC_VERSION=3.4.1

RUN \
    echo "Installing dependencies" && \
    apk add --no-cache --upgrade --virtual=build-dependencies \
        util-linux \
        build-base && \
    apk add --no-cache --upgrade \
        bash \
        cuetools \
        flac \
        findutils \
        coreutils \
        curl \
        p7zip && \

    echo "Building shntools" && \
    mkdir -p /tmp/shntool && \
    curl -SL http://shnutils.freeshell.org/shntool/dist/src/shntool-$SHNTOOL_VERSION.tar.gz \
        | tar -xzC /tmp/shntool --strip-components=1 && \
    cd /tmp/shntool && \
    ./configure \
        --infodir=/usr/share/info \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc && \
    make && \
    make install && \

    echo "Building ttaenc" && \
    mkdir -p /tmp/ttaenc && \
    curl -SL https://ixpeering.dl.sourceforge.net/project/tta/tta/ttaenc-src/ttaenc-$TTAENC_VERSION-src.tgz \
        | tar -xzC /tmp/ttaenc --strip-components=1 && \
    cd /tmp/ttaenc && \
    sed -i 's/def __uin/def uin/' ttaenc.h && \
    make && \
    make install && \

    echo "Cleaning up" \
    apk del --purge build-dependencies build-base && \
    rm -rf /tmp/*

COPY root/ /

ENTRYPOINT /bin/entrypoint.sh
CMD /bin/process-zips.sh
