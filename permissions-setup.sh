#!/bin/bash
# WordPress文件权限设置脚本

# 设置WordPress目录权限
sudo chown -R www-data:www-data /var/www/html/wp-site/
sudo find /var/www/html/wp-site/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/wp-site/ -type f -exec chmod 644 {} \;

# 设置wp-content目录权限（需要写入权限）
sudo chmod -R 775 /var/www/html/wp-site/wp-content/
sudo chown -R www-data:www-data /var/www/html/wp-site/wp-content/

# 设置wp-config.php文件权限（更严格）
sudo chmod 600 /var/www/html/wp-site/wp-config.php
sudo chown www-data:www-data /var/www/html/wp-site/wp-config.php

# 设置uploads目录权限（需要写入权限）
sudo chmod -R 775 /var/www/html/wp-site/wp-content/uploads/
sudo chown -R www-data:www-data /var/www/html/wp-site/wp-content/uploads/

# 设置.htaccess文件权限
sudo chmod 644 /var/www/html/wp-site/.htaccess
sudo chown www-data:www-data /var/www/html/wp-site/.htaccess

echo "文件权限设置完成!"