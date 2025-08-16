#!/bin/bash
# VPS服务器LAMP环境安装脚本

# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装Apache Web服务器
sudo apt install apache2 -y

# 启动并启用Apache服务
sudo systemctl start apache2
sudo systemctl enable apache2

# 安装MySQL数据库
sudo apt install mysql-server -y

# 启动并启用MySQL服务
sudo systemctl start mysql
sudo systemctl enable mysql

# 安装PHP和相关模块
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# 重启Apache以应用PHP模块
sudo systemctl restart apache2

# 配置防火墙（如果启用）
sudo ufw allow in "Apache Full"

# 创建WordPress数据库和用户
sudo mysql -e "CREATE DATABASE wp_video_site;"
sudo mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 安装Git
sudo apt install git -y

# 设置适当的文件权限
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

echo "LAMP环境安装完成!"