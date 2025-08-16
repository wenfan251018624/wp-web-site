#!/bin/bash
# 完整的自动部署脚本

# 设置变量
GITHUB_REPO="https://github.com/your-username/your-repo.git"
DEPLOY_PATH="/var/www/html/wp-site"
BRANCH="main"
DB_NAME="wp_video_site"
DB_USER="wp_user"
DB_PASSWORD="wp_password"
DB_HOST="localhost"

# 日志文件
LOG_FILE="/var/log/wp-deploy.log"

# 记录日志
log() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

# 开始部署
log "开始部署WordPress网站..."

# 更新系统包
log "更新系统包..."
sudo apt update >> $LOG_FILE 2>&1

# 检查是否已安装必要的软件包
log "检查必要软件包..."
if ! command -v git &> /dev/null; then
    log "安装Git..."
    sudo apt install git -y >> $LOG_FILE 2>&1
fi

if ! command -v mysql &> /dev/null; then
    log "安装MySQL..."
    sudo apt install mysql-server -y >> $LOG_FILE 2>&1
fi

if ! command -v apache2 &> /dev/null; then
    log "安装Apache..."
    sudo apt install apache2 -y >> $LOG_FILE 2>&1
fi

if ! command -v php &> /dev/null; then
    log "安装PHP..."
    sudo apt install php libapache2-mod-php php-mysql -y >> $LOG_FILE 2>&1
fi

# 创建部署目录
log "创建部署目录..."
sudo mkdir -p $DEPLOY_PATH
sudo chown www-data:www-data $DEPLOY_PATH

# 克隆或更新代码
log "克隆/更新代码..."
if [ ! -d "$DEPLOY_PATH/.git" ]; then
    sudo -u www-data git clone $GITHUB_REPO $DEPLOY_PATH >> $LOG_FILE 2>&1
else
    cd $DEPLOY_PATH
    sudo -u www-data git pull origin $BRANCH >> $LOG_FILE 2>&1
fi

# 设置目录权限
log "设置文件权限..."
sudo chown -R www-data:www-data $DEPLOY_PATH
sudo find $DEPLOY_PATH -type d -exec chmod 755 {} \;
sudo find $DEPLOY_PATH -type f -exec chmod 644 {} \;

# 配置WordPress数据库连接
log "配置WordPress数据库连接..."
cd $DEPLOY_PATH

if [ ! -f "wp-config.php" ] && [ -f "wp-config-sample.php" ]; then
    sudo cp wp-config-sample.php wp-config.php
fi

if [ -f "wp-config.php" ]; then
    sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
    sudo sed -i "s/username_here/$DB_USER/" wp-config.php
    sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
    sudo sed -i "s/localhost/$DB_HOST/" wp-config.php
    
    # 添加安全密钥
    sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-keys.tmp
    sudo sed -i '/#@+/,/#@-/c\#@+\n'"$(cat wp-keys.tmp)"'\n#@-' wp-config.php
    sudo rm wp-keys.tmp
    
    sudo chown www-data:www-data wp-config.php
    sudo chmod 600 wp-config.php
fi

# 重启Web服务器
log "重启Apache..."
sudo systemctl reload apache2 >> $LOG_FILE 2>&1

# 完成部署
log "部署完成!"

echo "WordPress网站部署成功完成！"
echo "详细日志请查看: $LOG_FILE"