FROM centos:7.6.1810 as builder

RUN mkdir -p /tmp/{ffmpeg,nginx} \
    && yum clean all && yum makecache fast \
    && yum install bzip2 gcc-c++ wget git file doxygen xmlto asciidoc make perl -y

RUN cd /tmp/ffmpeg \
    && wget https://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.gz \
    && tar -xf nasm-2.14.tar.gz \
    && cd nasm-2.14 \
    && ./configure \
    && make -j`nproc` && make install

RUN cd /tmp/ffmpeg \
    && wget ftp://ftp.videolan.org/pub/x264/snapshots/x264-snapshot-20181119-2245.tar.bz2 \
    && tar -xf x264-snapshot-20181119-2245.tar.bz2 \
    && cd x264-snapshot-20181119-2245 \
    && ./configure --enable-static --enable-shared \
    && make -j`nproc` && make install

RUN cd /tmp/ffmpeg \
    && wget https://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.xz \
    && tar -xf libogg-1.3.3.tar.xz \
    && cd libogg-1.3.3 \
    && ./configure \
    && make -j`nproc` && make install

RUN cd /tmp/ffmpeg \
    && echo "/usr/local/lib" >> /etc/ld.so.conf ; ldconfig \
    && wget https://ftp.osuosl.org/pub/xiph/releases/theora/libtheora-1.1.1.tar.gz \
    && tar -xf libtheora-1.1.1.tar.gz \
    && cd libtheora-1.1.1 \
    && ./configure \
    && make -j`nproc` && make install

RUN cd /tmp/ffmpeg \
    && wget https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2 \
    && tar -xf ffmpeg-4.1.tar.bz2 \
    && cd ffmpeg-4.1 \
    && ./configure --enable-shared --enable-pthreads --enable-gpl  --enable-avresample --enable-libx264 --enable-libtheora  --disable-yasm \
    && make -j`nproc` && make install

# NGINX
RUN cd /tmp/nginx \
    && ldconfig \
    && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz \
    && tar -xf pcre-8.40.tar.gz \
    && cd /tmp/nginx/pcre-8.40 \
    && ./configure && make -j`nproc` && make install

RUN cd /tmp/nginx \
    && wget http://zlib.net/zlib-1.2.11.tar.gz \
    && tar -xf zlib-1.2.11.tar.gz \
    && cd /tmp/nginx/zlib-1.2.11 \
    && ./configure && make -j`nproc` && make install

RUN cd /tmp/nginx \
    && wget https://www.openssl.org/source/old/1.1.0/openssl-1.1.0.tar.gz \
    && tar -xf openssl-1.1.0.tar.gz \
    && cd /tmp/nginx/openssl-1.1.0 \
    && ./config && make -j`nproc` && make install

RUN cd /tmp/nginx \
    && wget -O nginx-rtmp-module.tar.gz https://github.com/arut/nginx-rtmp-module/archive/master.tar.gz \
    && tar -xf nginx-rtmp-module.tar.gz

RUN cd /tmp/nginx \
    && wget http://nginx.org/download/nginx-1.12.0.tar.gz \
    && tar -xf nginx-1.12.0.tar.gz \
    && cd /tmp/nginx/nginx-1.12.0/ \
    && ./configure --prefix=/usr/local/nginx \
         --with-pcre=/tmp/nginx/pcre-8.40 \
         --with-zlib=/tmp/nginx/zlib-1.2.11 \
         --with-openssl=/tmp/nginx/openssl-1.1.0  \
         --with-http_ssl_module \
         --add-module=/tmp/nginx/nginx-rtmp-module-master \
    && make -j`nproc` && make install \
    && rm -rf /tmp/nginx/*

STOPSIGNAL SIGTERM

FROM centos:7.6.1810

COPY --from=builder /usr/local /usr/local

RUN yum makecache fast \
    && yum install file -y \
    && yum clean all \
    && echo "/usr/local/lib" >> /etc/ld.so.conf \
    && ldconfig

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

ENV PATH $PATH:/usr/local/nginx/sbin

RUN mkdir /opt/{media,hls,live,stream}

VOLUME ["/opt/media", "/opt/hls", "/opt/live", "/opt/stream"]

WORKDIR /opt

EXPOSE 80 1935

COPY ./scripts /scripts
COPY docker-entrapoint.sh /usr/bin

CMD ["docker-entrapoint.sh"]
