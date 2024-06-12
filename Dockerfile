FROM php:7.4-apache-buster as base_image

# 换 aliyun 源
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    && sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list
# 修改时区
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone

RUN apt-get update \
    && apt-get install -y vim cron libmagickwand-dev imagemagick libzip-dev zip unzip default-mysql-client
RUN docker-php-ext-install intl bcmath zip \
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    && pecl install -o -f http://pecl.php.net/get/redis-5.0.0.tgz \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable opcache \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pcntl
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /var/log/lastlog /var/log/faillog
FROM base_image

ARG LARAVEL_PATH=/var/www/laravel
WORKDIR ${LARAVEL_PATH}
COPY . ${LARAVEL_PATH}
RUN cd ${LARAVEL_PATH} \
      && chown -R www-data:www-data ${LARAVEL_PATH} \
      && mv .env.example .env

RUN rm /etc/apache2/sites-enabled/*
COPY docker/config/apache2 /etc/apache2/
RUN a2enmod rewrite headers \
    && a2ensite laravel

COPY docker/entrypoint.sh /usr/local/bin/entrypoint
COPY docker/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/entrypoint \
    && chmod +x /usr/local/bin/wait-for-it

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint"]
