# WordPress视频网站VPS部署指南

本文档详细介绍了如何将WordPress视频网站部署到Linux VPS服务器上。

## 目录

1. [系统要求](#系统要求)
2. [一键部署](#一键部署)
3. [手动部署步骤](#手动部署步骤)
4. [部署后配置](#部署后配置)
5. [故障排除](#故障排除)

## 系统要求

- Ubuntu 20.04 LTS 或更高版本
- 至少2GB内存
- 至少20GB磁盘空间
- Root或sudo权限

## 一键部署

### 方法1：使用完整部署脚本

```bash
# 下载部署脚本
wget https://raw.githubusercontent.com/your-username/your-repo/main/vps-deployment/vps-deploy-complete.sh

# 给脚本执行权限
chmod +x vps-deploy-complete.sh

# 运行部署脚本
sudo bash vps-deploy-complete.sh https://github.com/wenfan251018624/wp-web-site.git /var/www/html/wp-site
```

### 方法2：使用快速部署脚本

```bash
# 下载快速部署脚本
wget https://raw.githubusercontent.com/your-username/your-repo/main/vps-deployment/quick-deploy.sh

# 给脚本执行权限
chmod +x quick-deploy.sh

# 运行部署脚本
sudo bash quick-deploy.sh
```

## 手动部署步骤

### 1. 更新系统

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. 安装LAMP环境

```bash
# 安装Apache
sudo apt install apache2 -y

# 安装MySQL
sudo apt install mysql-server -y

# 安装PHP及相关模块
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
```

### 3. 启动并启用服务

```bash
# 启动Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# 启动MySQL
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 4. 配置MySQL数据库

```bash
# 安全配置MySQL（可选但推荐）
sudo mysql_secure_installation

# 登录MySQL并创建数据库
sudo mysql -e "CREATE DATABASE wp_video_site;"
sudo mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

### 5. 克隆代码仓库

```bash
# 创建网站目录
sudo mkdir -p /var/www/html/wp-site
sudo chown www-data:www-data /var/www/html/wp-site

# 克隆仓库
sudo -u www-data git clone https://github.com/wenfan251018624/wp-web-site.git /var/www/html/wp-site
```

### 6. 配置WordPress

```bash
# 进入网站目录
cd /var/www/html/wp-site

# 配置wp-config.php
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wp_video_site/" wp-config.php
sudo sed -i "s/username_here/wp_user/" wp-config.php
sudo sed -i "s/password_here/wp_password/" wp-config.php

# 设置文件权限
sudo chown -R www-data:www-data /var/www/html/wp-site
sudo find /var/www/html/wp-site -type d -exec chmod 755 {} \;
sudo find /var/www/html/wp-site -type f -exec chmod 644 {} \;
```

### 7. 配置Apache虚拟主机

```bash
# 创建虚拟主机配置文件
sudo nano /etc/apache2/sites-available/wordpress.conf
```

添加以下内容：

```apache
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wp-site
    ServerName your-domain.com
    
    <Directory /var/www/html/wp-site>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

启用站点并重启Apache：

```bash
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl reload apache2
```

## 部署后配置

### 1. 访问网站

打开浏览器，访问您的服务器IP地址或域名，您将看到WordPress安装页面。

### 2. 完成WordPress安装

按照WordPress安装向导完成网站设置。

### 3. 配置域名（可选）

将您的域名DNS指向服务器IP地址。

### 4. 配置SSL证书（推荐）

使用Let's Encrypt免费SSL证书：

```bash
sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d your-domain.com
```

### 5. 安全配置

1. 修改默认数据库密码
2. 删除不必要的文件
3. 配置防火墙

```bash
# 配置UFW防火墙
sudo ufw enable
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
```

## 故障排除

### 常见问题

1. **网站无法访问**
   - 检查防火墙设置
   - 检查Apache是否正在运行
   - 检查虚拟主机配置

2. **数据库连接错误**
   - 检查数据库名称、用户名和密码
   - 检查MySQL服务是否正在运行

3. **权限错误**
   - 检查文件和目录权限
   - 确保www-data用户有适当权限

### 查看日志

```bash
# Apache错误日志
sudo tail -f /var/log/apache2/error.log

# MySQL错误日志
sudo tail -f /var/log/mysql/error.log

# 系统日志
sudo journalctl -u apache2
sudo journalctl -u mysql
```

### 重新部署

如果需要重新部署，可以使用以下命令清理环境：

```bash
# 删除网站文件
sudo rm -rf /var/www/html/wp-site

# 删除数据库
sudo mysql -e "DROP DATABASE wp_video_site;"
sudo mysql -e "DROP USER 'wp_user'@'localhost';"
```

然后重新运行部署脚本。

## 支持

如有问题，请联系：[您的联系方式]