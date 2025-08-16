#!/bin/bash
# 完整的VPS部署脚本 - 一键部署WordPress视频网站

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查root权限
check_root() {
    if [[ $EUID -eq 0 ]]; then
        success "以root权限运行"
    else
        error "此脚本需要root权限运行"
        error "请使用 'sudo bash vps-deploy-complete.sh' 命令运行"
        exit 1
    fi
}

# 检查系统类型
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log "检测到操作系统: $OS $VER"
    else
        error "无法检测操作系统类型"
        exit 1
    fi
}

# 更新系统包
update_system() {
    log "更新系统包..."
    apt update -y >> /var/log/wp-deploy.log 2>&1
    success "系统包更新完成"
}

# 安装必要的软件包
install_packages() {
    log "检查并安装必要的软件包..."
    
    # 安装Git
    if ! command -v git &> /dev/null; then
        log "安装Git..."
        apt install git -y >> /var/log/wp-deploy.log 2>&1
    fi
    
    # 安装Apache
    if ! command -v apache2 &> /dev/null; then
        log "安装Apache..."
        apt install apache2 -y >> /var/log/wp-deploy.log 2>&1
    fi
    
    # 安装MySQL
    if ! command -v mysql &> /dev/null; then
        log "安装MySQL..."
        apt install mysql-server -y >> /var/log/wp-deploy.log 2>&1
    fi
    
    # 安装PHP及相关模块
    if ! command -v php &> /dev/null; then
        log "安装PHP及相关模块..."
        apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y >> /var/log/wp-deploy.log 2>&1
    fi
    
    success "必要软件包安装完成"
}

# 启动并启用服务
enable_services() {
    log "启动并启用系统服务..."
    
    # 启动Apache
    systemctl start apache2 >> /var/log/wp-deploy.log 2>&1
    systemctl enable apache2 >> /var/log/wp-deploy.log 2>&1
    
    # 启动MySQL
    systemctl start mysql >> /var/log/wp-deploy.log 2>&1
    systemctl enable mysql >> /var/log/wp-deploy.log 2>&1
    
    success "系统服务已启动并设置为开机自启"
}

# 配置MySQL数据库
configure_mysql() {
    log "配置MySQL数据库..."
    
    # 设置MySQL root密码（如果尚未设置）
    mysql_secure_installation <<EOF

y
y
n
y
y
EOF

    # 创建WordPress数据库和用户
    mysql -e "CREATE DATABASE IF NOT EXISTS wp_video_site;" >> /var/log/wp-deploy.log 2>&1
    mysql -e "CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';" >> /var/log/wp-deploy.log 2>&1
    mysql -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';" >> /var/log/wp-deploy.log 2>&1
    mysql -e "FLUSH PRIVILEGES;" >> /var/log/wp-deploy.log 2>&1
    
    success "MySQL数据库配置完成"
}

# 克隆代码仓库
clone_repository() {
    local repo_url=$1
    local deploy_path=$2
    
    log "克隆代码仓库..."
    
    # 创建部署目录
    mkdir -p $deploy_path
    chown www-data:www-data $deploy_path
    
    # 克隆仓库
    if [ ! -d "$deploy_path/.git" ]; then
        sudo -u www-data git clone $repo_url $deploy_path >> /var/log/wp-deploy.log 2>&1
    else
        cd $deploy_path
        sudo -u www-data git pull origin main >> /var/log/wp-deploy.log 2>&1
    fi
    
    success "代码仓库克隆完成"
}

# 配置WordPress
configure_wordpress() {
    local wp_path=$1
    
    log "配置WordPress..."
    cd $wp_path
    
    # 如果wp-config.php不存在，从示例文件复制
    if [ ! -f "wp-config.php" ] && [ -f "wp-config-sample.php" ]; then
        sudo cp wp-config-sample.php wp-config.php
    fi
    
    # 设置数据库配置
    sudo sed -i "s/database_name_here/wp_video_site/" wp-config.php
    sudo sed -i "s/username_here/wp_user/" wp-config.php
    sudo sed -i "s/password_here/wp_password/" wp-config.php
    sudo sed -i "s/localhost/localhost/" wp-config.php
    
    # 添加安全密钥
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ > wp-keys.tmp
    sudo sed -i '/#@+/,/#@-/c\#@+\'"$(cat wp-keys.tmp)"'\n#@-' wp-config.php
    rm wp-keys.tmp
    
    # 设置文件权限
    chown www-data:www-data wp-config.php
    chmod 600 wp-config.php
    
    # 设置目录权限
    chown -R www-data:www-data $wp_path
    find $wp_path -type d -exec chmod 755 {} \;
    find $wp_path -type f -exec chmod 644 {} \;
    
    success "WordPress配置完成"
}

# 配置Apache虚拟主机
configure_apache() {
    local deploy_path=$1
    
    log "配置Apache虚拟主机..."
    
    # 创建Apache配置文件
    cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $deploy_path
    ServerName your-domain.com  # 请替换为您的域名
    
    <Directory $deploy_path>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    # 禁用默认站点，启用WordPress站点
    a2dissite 000-default.conf >> /var/log/wp-deploy.log 2>&1
    a2ensite wordpress.conf >> /var/log/wp-deploy.log 2>&1
    
    # 启用rewrite模块
    a2enmod rewrite >> /var/log/wp-deploy.log 2>&1
    
    # 重启Apache
    systemctl reload apache2 >> /var/log/wp-deploy.log 2>&1
    
    success "Apache配置完成"
}

# 主部署函数
main_deploy() {
    local repo_url=$1
    local deploy_path=$2
    
    log "开始部署WordPress视频网站..."
    
    # 检查参数
    if [ -z "$repo_url" ] || [ -z "$deploy_path" ]; then
        error "使用方法: $0 <repository_url> <deploy_path>"
        error "示例: $0 https://github.com/your-username/your-repo.git /var/www/html/wp-site"
        exit 1
    fi
    
    check_root
    check_os
    update_system
    install_packages
    enable_services
    configure_mysql
    clone_repository "$repo_url" "$deploy_path"
    configure_wordpress "$deploy_path"
    configure_apache "$deploy_path"
    
    success "WordPress视频网站部署完成！"
    log "请访问 http://your-server-ip 查看网站"
    log "请将Apache配置文件中的域名替换为您的实际域名"
    log "详细日志请查看: /var/log/wp-deploy.log"
}

# 如果没有提供参数，则显示使用方法
if [ $# -eq 0 ]; then
    echo "WordPress视频网站VPS部署脚本"
    echo "=============================="
    echo "使用方法:"
    echo "  sudo bash $0 <repository_url> <deploy_path>"
    echo ""
    echo "参数说明:"
    echo "  repository_url  - GitHub仓库URL"
    echo "  deploy_path     - 部署路径"
    echo ""
    echo "示例:"
    echo "  sudo bash $0 https://github.com/your-username/your-repo.git /var/www/html/wp-site"
    echo ""
    exit 1
fi

# 执行主部署函数
main_deploy "$1" "$2"