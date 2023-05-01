FROM ubuntu:22.04

LABEL maintainer="Timur Zhenguldinov"

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

ENV PHP_FPM_PM_MAX_CHILDREN=5
ENV PHP_FPM_PM_START_SERVERS=2
ENV PHP_FPM_PM_MIN_SPARE_SERVERS=1
ENV PHP_FPM_PM_MAX_SPARE_SERVERS=3
ENV PHP_FPM_PM_PROCESS_IDLE_TIMEOUT=10s
ENV PHP_FPM_PM_MAX_REQUESTS=500
ENV PHP_FPM_LISTEN=0.0.0.0:9000
ENV PHP_FPM_PM=dynamic

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
   && apt-get install -y gnupg curl ca-certificates zip unzip nginx supervisor libcap2-bin libpng-dev \
   && mkdir -p ~/.gnupg \
   && chmod 600 ~/.gnupg \
   && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
   && echo "keyserver hkp://keyserver.ubuntu.com:80" >> ~/.gnupg/dirmngr.conf \
   && gpg --recv-key 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c \
   && gpg --export 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c > /usr/share/keyrings/ppa_ondrej_php.gpg \
   && echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
   && apt-get update \
   && apt-get install -y php8.1 php8.1-fpm php8.1-opcache \
      php8.1-pgsql php8.1-sqlite3 php8.1-gd \
      php8.1-curl \
      php8.1-imap php8.1-mysql php8.1-mbstring \
      php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
      php8.1-intl php8.1-readline \
      php8.1-ldap \
      php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
      php8.1-memcached php8.1-pcov  \
   && apt-get -y autoremove \
   && apt-get -y autoclean \
   && apt-get -y clean \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

STOPSIGNAL SIGKILL

COPY ./rootfs /

RUN chmod +x /usr/bin/docker-entrypoint.sh \
   && chmod +x /usr/bin/start-container \
   && ln -sf /dev/stdout /var/log/nginx/access.log \ 
   && ln -sf /dev/stderr /var/log/nginx/error.log 

ENTRYPOINT docker-entrypoint.sh
CMD start-container
