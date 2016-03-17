FROM evild/alpine-base:1.0.0
MAINTAINER Dominique HAAS <contact@dominique-haas.fr>

ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763


ENV PHP_VERSION 7.0.4
ENV PHP_FILENAME php-${PHP_VERSION}.tar.xz
ENV PHP_SHA256 584e0e374e357a71b6e95175a2947d787453afc7f9ab7c55651c10491c4df532

RUN \
  build_pkgs="build-base xz re2c file readline-dev autoconf binutils bison \
  libxml2-dev curl-dev freetype-dev openssl-dev libjpeg-turbo-dev libpng-dev \
  libwebp-dev libmcrypt-dev gmp-dev icu-dev libmemcached-dev wget git gnupg" \
  && runtime_pkgs="curl zlib tar make libxml2 readline freetype openssl \
  libjpeg-turbo libpng libmcrypt libwebp icu" \
  && apk --no-cache add ${build_pkgs} ${runtime_pkgs} \
	&& set -xe \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done \
	&& mkdir /tmp/php && cd /tmp/php \
  && curl -fSL "http://php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
  && echo "$PHP_SHA256 *$PHP_FILENAME" | sha256sum -c - \
	&& curl -fSL "http://php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o "$PHP_FILENAME.asc" \
	&& gpg --verify "$PHP_FILENAME.asc" "$PHP_FILENAME" \
	&& mkdir -p /usr/src/php \
	&& tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
  && cd /usr/src/php \
  && ./buildconf --force \
  && ./configure \
      --prefix=/usr \
      --sysconfdir=/etc/php \
      --with-config-file-path=/etc/php \
      --with-config-file-scan-dir=/etc/php/conf.d \
      --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data \
      --enable-cli \
      --enable-mbstring \
      --enable-zip \
      --enable-ftp \
      --enable-bcmath \
      --enable-opcache \
      --enable-pcntl \
      --enable-mysqlnd \
      --enable-gd-native-ttf \
      --enable-sockets \
      --enable-exif \
      --enable-soap \
      --enable-calendar \
      --enable-intl \
      --enable-json \
      --enable-dom \
      --enable-libxml --with-libxml-dir=/usr \
      --enable-xml \
      --enable-xmlreader \
      --enable-phar \
      --enable-session \
      --enable-sysvmsg \
      --enable-sysvsem \
      --enable-sysvshm \
      --disable-cgi \
      --disable-debug \
      --disable-rpath \
      --disable-static \
      --disable-phpdbg \
      --with-libdir=/lib/x86_64-linux-gnu \
      --with-curl \
      --with-mcrypt \
      --with-iconv \
      --with-gd --with-jpeg-dir=/usr --with-webp-dir=/usr --with-png-dir=/usr \
      --with-freetype-dir=/usr \
      --with-zlib --with-zlib-dir=/usr \
      --with-openssl \
      --with-mhash \
      --with-pcre-regex \
      --with-pdo-mysql \
      --with-mysqli \
      --with-readline \
      --with-xmlrpc \
      --with-pear \
  && make \
  && make install \
  && make clean \
  && strip -s /usr/bin/php \
  && apk del ${build_pkgs} \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && mkdir -p /var/lib/php7/sessions \
  && cd / \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && rm -rf /var/www/* \
  && rm -rf /usr/src/* \
  && adduser -D www-data
ADD root /

EXPOSE 9000
