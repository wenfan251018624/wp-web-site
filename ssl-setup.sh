#!/bin/bash
# SSL证书配置脚本（使用Let's Encrypt）

# 设置变量
DOMAIN="your-domain.com"
WWW_DOMAIN="www.your-domain.com"
EMAIL="your-email@example.com"
WEB_ROOT="/var/www/html/wp-site"

# 更新系统包
sudo apt update

# 安装Certbot
sudo apt install certbot python3-certbot-apache -y

# 获取SSL证书
sudo certbot --apache \
    -d $DOMAIN \
    -d $WWW_DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --redirect \
    --hsts \
    --staple-ocsp \
    --must-staple

# 设置自动续期
# 添加到crontab
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

# 重启Apache以应用更改
sudo systemctl reload apache2

echo "SSL证书配置完成!"
echo "证书将自动续期"