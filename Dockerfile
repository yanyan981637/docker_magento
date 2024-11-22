# 使用 PHP 8.3 FPM 基礎映像
FROM php:8.3-fpm

# 安裝必要的 PHP 擴展及 MySQL 客戶端
RUN apt-get update && \
    apt-get install -y libicu-dev libzip-dev libxslt-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev default-mysql-client && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql intl bcmath gd soap xsl zip sockets && \
    docker-php-ext-enable intl bcmath gd soap xsl zip sockets

# 設置 PHP 配置
RUN echo "memory_limit = 2G" > /usr/local/etc/php/conf.d/custom-memory-limit.ini && \
    echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" > /usr/local/etc/php/conf.d/custom-error-reporting.ini

# 設置目錄權限腳本
COPY set-permissions.sh /usr/local/bin/set-permissions.sh
RUN chmod +x /usr/local/bin/set-permissions.sh

# 清理緩存以減少映像大小
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
