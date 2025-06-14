# 使用 PHP 8.2 FPM 基礎映像
FROM php:8.2-fpm

# 安裝必要的 PHP 擴展及 MySQL 客戶端
RUN apt-get update && \
    apt-get install -y libicu-dev libzip-dev libxslt-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev unzip default-mysql-client curl gnupg && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql intl bcmath gd soap xsl zip sockets && \
    docker-php-ext-enable intl bcmath gd soap xsl zip sockets

# 安裝 Node.js 和 NPM，並鎖定版本
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g n && \
    n 20.18.1 && \
    npm install -g npm@10.8.2 && \
    npm cache clean --force && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安裝 Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# 設置 PHP 配置
RUN echo "memory_limit = 4096M" > /usr/local/etc/php/conf.d/custom-memory-limit.ini && \
    echo "upload_max_filesize = 256M" > /usr/local/etc/php/conf.d/custom-upload-limit.ini && \
    echo "post_max_size = 256M" >> /usr/local/etc/php/conf.d/custom-upload-limit.ini 

# 新增：為 Magento 調整輸入變數與執行時間等限制
RUN echo "max_input_vars = 20000" > /usr/local/etc/php/conf.d/custom-limits.ini && \
    echo "max_execution_time = 1800" >> /usr/local/etc/php/conf.d/custom-limits.ini && \
    echo "max_input_time = 1800" >> /usr/local/etc/php/conf.d/custom-limits.ini
    # 如果需要可加上你環境中額外需要的設定
    # e.g. echo "max_multipart_body_parts = 20000" >> /usr/local/etc/php/conf.d/custom-limits.ini

# 配置 PHP-FPM 行程設定 (若需要)
# RUN echo "pm = dynamic" >> /usr/local/etc/php-fpm.d/zz-dynamic.conf && \
#     echo "pm.max_children = 50" >> /usr/local/etc/php-fpm.d/zz-dynamic.conf && \
#     echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/zz-dynamic.conf && \
#     echo "pm.max_spare_servers = 35" >> /usr/local/etc/php-fpm.d/zz-dynamic.conf && \
#     echo "pm.max_requests = 500" >> /usr/local/etc/php-fpm.d/zz-dynamic.conf

# 確保網站目錄的權限正確
COPY set-permissions.sh /usr/local/bin/set-permissions.sh
RUN chmod +x /usr/local/bin/set-permissions.sh

# 安裝 OPCache 並啟用（可選，但推薦）
# RUN docker-php-ext-install opcache && \
#     echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
#     echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
#     echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
#     echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
#     echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache-recommended.ini && \
#     echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache-recommended.ini

# 清理緩存以減少映像大小
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
