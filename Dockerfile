FROM php:8.1-fpm-bullseye

# install the PHP extensions we need
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libwebp-dev \
		libpq-dev \
		libzip-dev \
		jpegoptim \
		optipng \
		pngcrush \
		pngquant \
		libjpeg-progs \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
	pecl install redis-5.3.7; \
	docker-php-ext-enable redis; \
	\
	pecl install apcu; \
        docker-php-ext-enable apcu; \
	\
	pecl clear-cache \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo \
       rsync \
       mariadb-client \
       unzip \
       git \
       imagemagick \
       graphicsmagick \
       pngquant \
       optipng \
       jpegoptim \
       gifsicle \
       libjpeg-turbo-progs \
    && echo "www-data:www-data" | chpasswd \
    && adduser www-data sudo \
    && rm -rf /var/lib/apt/lists/*

# Use the default production configuration
# Do do that now, and find out, why $_ENV is missing with that.
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Override and set recommended php.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Override default settings, to get it running with Drupal smoothly.
RUN { \
		echo 'upload_max_filesize = 20M'; \
		echo 'post_max_size = 20M'; \
		echo 'memory_limit = 256M'; \
	} > /usr/local/etc/php/conf.d/custom-settings.ini

# Disable access.log on php-fpm level in docker logs
RUN sed -i  s'/access.log = \/proc\/self\/fd\/2/access.log = \/proc\/self\/fd\/1/' /usr/local/etc/php-fpm.d/docker.conf

# Install drush launcher to use the drush version of the project.
ARG DRUSH_LAUNCHER_VERSION=0.10.1

# Install drush launcher with the phar file.
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush-launcher/releases/download/$DRUSH_LAUNCHER_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush

# Set the path variable to use drush directly from this project.
ENV PATH="/var/www/html/web/vendor/bin:${PATH}"

# Install Composer
COPY --from=composer:2.4.4 /usr/bin/composer /usr/bin/composer
RUN composer --version
