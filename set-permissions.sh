#!/bin/bash
# 設置 /data/enterprise 目錄及其子目錄的權限
echo "Setting permissions for /data/enterprise..."
find /data/enterprise -type d -exec chmod 775 {} +
find /data/enterprise -type f -exec chmod 664 {} +
chmod -R g+w /data/enterprise/var/log /data/enterprise/var/session
chown -R www-data:www-data /data/enterprise

# 確保 Magento CLI 工具有執行權限
echo "Setting executable permission for bin/magento..."
chmod +x /data/enterprise/bin/magento