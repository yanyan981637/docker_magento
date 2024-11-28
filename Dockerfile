# 使用 PHP 8.2 FPM 基礎映像
FROM php:8.2-fpm

# 安裝必要的 PHP 擴展及 MySQL 客戶端
RUN apt-get update && \
    apt-get install -y libicu-dev libzip-dev libxslt-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev unzip default-mysql-client && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql intl bcmath gd soap xsl zip sockets && \
    docker-php-ext-enable intl bcmath gd soap xsl zip sockets

# 安裝 Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# 設置 PHP 配置
RUN echo "memory_limit = 2G" > /usr/local/etc/php/conf.d/custom-memory-limit.ini && \
    echo "upload_max_filesize = 256M" > /usr/local/etc/php/conf.d/custom-upload-limit.ini && \
    echo "post_max_size = 256M" >> /usr/local/etc/php/conf.d/custom-upload-limit.ini 

# 確保網站目錄的權限正確
COPY set-permissions.sh /usr/local/bin/set-permissions.sh
RUN chmod +x /usr/local/bin/set-permissions.sh

# 安裝 OPCache 並啟用（可選，但推薦）
RUN docker-php-ext-install opcache && \
    echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache-recommended.ini

# 清理緩存以減少映像大小
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
