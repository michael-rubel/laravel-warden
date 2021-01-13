FROM docker.io/wardenenv/php-fpm:${PHP_VERSION:-7.4}${WARDEN_SVC_PHP_VARIANT:-}

RUN sudo yum install -y php-pgsql \
    && sudo yum clean all \
    && sudo rm -rf /var/cache/yum

WORKDIR /var/www/html
USER www-data
