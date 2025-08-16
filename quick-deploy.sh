#!/bin/bash
# 快速部署脚本 - 一键部署WordPress视频网站

# 设置变量
GITHUB_REPO="https://github.com/wenfan251018624/wp-web-site.git"
DEPLOY_PATH="/var/www/html/wp-site"

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要root权限运行"
   echo "请使用 'sudo bash quick-deploy.sh' 命令运行"
   exit 1
fi

echo "开始部署WordPress视频网站..."
echo "=============================="

# 更新系统包
echo "1. 更新系统包..."
apt update -y > /dev/null 2>&1

# 安装必要的软件包
echo "2. 安装必要的软件包..."
apt install git apache2 mysql-server php libapache2-mod-php php-mysql -y > /dev/null 2>&1

# 启动服务
echo "3. 启动系统服务..."
systemctl start apache2
systemctl start mysql
systemctl enable apache2 > /dev/null 2>&1
systemctl enable mysql > /dev/null 2>&1

# 配置MySQL数据库
echo "4. 配置MySQL数据库..."
mysql -e "CREATE DATABASE IF NOT EXISTS wp_video_site;"
mysql -e "CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';"
mysql -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 创建部署目录
echo "5. 克隆代码仓库..."
mkdir -p $DEPLOY_PATH
chown www-data:www-data $DEPLOY_PATH

# 克隆仓库
if [ ! -d "$DEPLOY_PATH/.git" ]; then
    sudo -u www-data git clone $GITHUB_REPO $DEPLOY_PATH
else
    cd $DEPLOY_PATH
    sudo -u www-data git pull origin main
fi

# 配置WordPress
echo "6. 配置WordPress..."
cd $DEPLOY_PATH

# 设置数据库配置
if [ -f "wp-config.php" ]; then
    sudo sed -i "s/database_name_here/wp_video_site/" wp-config.php
    sudo sed -i "s/username_here/wp_user/" wp-config.php
    sudo sed -i "s/password_here/wp_password/" wp-config.php
    sudo sed -i "s/localhost/localhost/" wp-config.php
fi

# 设置文件权限
chown -R www-data:www-data $DEPLOY_PATH
find $DEPLOY_PATH -type d -exec chmod 755 {} \;
find $DEPLOY_PATH -type f -exec chmod 644 {} \;

# 配置Apache
echo "7. 配置Apache..."
cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $DEPLOY_PATH
    ServerName your-domain.com
    
    <Directory $DEPLOY_PATH>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# 启用站点
a2dissite 000-default.conf > /dev/null 2>&1
a2ensite wordpress.conf > /dev/null 2>&1
a2enmod rewrite > /dev/null 2>&1

# 重启Apache
systemctl reload apache2

echo "=============================="
echo "部署完成！"
echo ""
echo "请访问 http://your-server-ip 查看网站"
echo "请将Apache配置文件中的域名替换为您的实际域名"
echo ""
echo "注意："
echo "1. 请确保端口80已在防火墙中开放"
echo "2. 如需SSL证书，请手动配置"
echo "3. 建议在生产环境中修改默认的数据库密码"