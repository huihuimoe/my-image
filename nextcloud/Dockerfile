# https://hub.docker.com/_/nextcloud
ARG TAG=fpm-alpine
FROM nextcloud:${TAG}

COPY txt.patch /
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmemcached-dev \
        libxml2-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        imagemagick-dev \
    ; \
    pecl install mcrypt-snapshot imagick-stable; \
    docker-php-ext-enable mcrypt imagick; \
    apk del .build-deps; \
    apk add --no-cache libmcrypt imagemagick-libs imagemagick-svg samba-client procps imagemagick rsync; \
    mkdir /usr/share/fonts || true ; \
    cd /usr/share/fonts ; \
    wget \
    https://raw.githubusercontent.com/googlefonts/noto-cjk/main/Sans/Variable/OTC/NotoSansCJK-VF.otf.ttc \
    -O NotoSansCJK-Regular.ttc && \
    fc-cache -fv && \
    cd / && \
    apk add --no-cache patch && \
    patch -p1 < txt.patch && \
    rm txt.patch && \
    apk del patch
#COPY 14913.patch /usr/src/nextcloud/
#RUN cd /usr/src/nextcloud && \
#    patch -p1 < 14913.patch && \
#    rm 14913.patch
# minio patch file
# https://github.com/nextcloud/server/issues/6954
# RUN curl -sfL https://github.com/nextcloud/server/raw/bugfix/6954/scan-external-s3/apps/files_external/lib/Lib/Storage/AmazonS3.php > /usr/src/nextcloud/apps/files_external/lib/Lib/Storage/AmazonS3.php;

