#!/bin/bash
# WordPress视频网站跨平台部署脚本
# 支持Linux和Mac系统

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 全局变量
OS_TYPE=""
CURRENT_USER=""
DEPLOY_PATH=""

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

# 检测操作系统类型
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="mac"
        CURRENT_USER=$(whoami)
        success "检测到Mac操作系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        CURRENT_USER=$(whoami)
        # 检查是否为root用户
        if [[ $EUID -eq 0 ]]; then
            CURRENT_USER="root"
        fi
        success "检测到Linux操作系统"
    else
        error "不支持的操作系统类型: $OSTYPE"
        exit 1
    fi
}

# 检查root权限（仅Linux需要）
check_root() {
    if [[ "$OS_TYPE" == "linux" ]]; then
        if [[ $EUID -ne 0 ]]; then
            error "此脚本在Linux系统上需要root权限运行"
            error "请使用 'sudo bash deploy-universal.sh' 命令运行"
            exit 1
        else
            success "以root权限运行"
        fi
    fi
}

# 检查必要的软件包
check_prerequisites() {
    log "检查必要的软件包..."
    
    local missing_packages=()
    
    # 检查Git
    if ! command -v git &> /dev/null; then
        missing_packages+=("git")
    fi
    
    # 检查Apache/HTTPD
    if [[ "$OS_TYPE" == "mac" ]]; then
        if ! command -v httpd &> /dev/null && ! command -v apachectl &> /dev/null; then
            missing_packages+=("Apache (httpd)")
        fi
    else
        if ! command -v apache2 &> /dev/null; then
            missing_packages+=("apache2")
        fi
    fi
    
    # 检查MySQL
    if ! command -v mysql &> /dev/null; then
        missing_packages+=("MySQL")
    fi
    
    # 检查PHP
    if ! command -v php &> /dev/null; then
        missing_packages+=("PHP")
    fi
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        error "缺少必要的软件包: ${missing_packages[*]}"
        if [[ "$OS_TYPE" == "mac" ]]; then
            log "请安装必要的软件包，推荐使用Homebrew："
            log "  brew install git mysql php httpd"
        else
            log "请安装必要的软件包："
            log "  sudo apt update && sudo apt install git mysql-server apache2 php libapache2-mod-php php-mysql -y"
        fi
        exit 1
    fi
    
    success "所有必要的软件包已安装"
}

# 启动MySQL服务（Mac专用）
start_mysql_mac() {
    log "启动MySQL服务..."
    
    # 检查MySQL是否已在运行
    if mysqladmin ping &> /dev/null; then
        success "MySQL服务已在运行"
        return
    fi
    
    # 尝试启动MySQL（通过Homebrew安装的情况）
    if command -v brew &> /dev/null; then
        brew services start mysql > /dev/null 2>&1
        sleep 5
        
        # 再次检查MySQL是否已启动
        if mysqladmin ping &> /dev/null; then
            success "MySQL服务启动完成"
            return
        fi
    fi
    
    # 如果以上方法都不行，提示用户手动启动
    warning "无法自动启动MySQL服务"
    log "请手动启动MySQL服务："
    log "  brew services start mysql"
    log "或者使用系统偏好设置中的MySQL启动"
    read -p "请手动启动MySQL服务后按回车继续..."
}

# 启动MySQL服务（Linux专用）
start_mysql_linux() {
    log "启动MySQL服务..."
    
    # 启动MySQL服务
    systemctl start mysql > /dev/null 2>&1
    systemctl enable mysql > /dev/null 2>&1
    
    # 等待MySQL启动
    local retry_count=0
    while ! mysqladmin ping &> /dev/null; do
        if [ $retry_count -gt 10 ]; then
            error "MySQL服务启动超时"
            exit 1
        fi
        log "等待MySQL服务启动... ($retry_count/10)"
        sleep 3
        retry_count=$((retry_count + 1))
    done
    
    success "MySQL服务启动完成"
}

# 启动MySQL服务（根据操作系统）
start_mysql() {
    if [[ "$OS_TYPE" == "mac" ]]; then
        start_mysql_mac
    else
        start_mysql_linux
    fi
}

# 配置MySQL数据库
configure_database() {
    log "配置MySQL数据库..."
    
    # 等待MySQL完全启动
    local retry_count=0
    while ! mysqladmin ping &> /dev/null; do
        if [ $retry_count -gt 10 ]; then
            error "MySQL服务启动超时"
            exit 1
        fi
        log "等待MySQL服务启动... ($retry_count/10)"
        sleep 3
        retry_count=$((retry_count + 1))
    done
    
    # 设置MySQL root密码（仅Linux）
    if [[ "$OS_TYPE" == "linux" ]]; then
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';" > /dev/null 2>&1
        mysql -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
    fi
    
    # 从db-setup.sql文件读取数据库配置
    if [ -f "db-setup.sql" ]; then
        log "从db-setup.sql文件读取数据库配置..."
        if [[ "$OS_TYPE" == "linux" ]]; then
            mysql -u root -prootpassword < db-setup.sql > /dev/null 2>&1
        else
            mysql -u root < db-setup.sql > /dev/null 2>&1
        fi
        success "数据库配置完成"
    else
        # 使用默认配置
        log "使用默认数据库配置..."
        if [[ "$OS_TYPE" == "linux" ]]; then
            mysql -u root -prootpassword -e "CREATE DATABASE IF NOT EXISTS wp_video_site;" > /dev/null 2>&1
            mysql -u root -prootpassword -e "CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';" > /dev/null 2>&1
            mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';" > /dev/null 2>&1
            mysql -u root -prootpassword -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
        else
            mysql -u root -e "CREATE DATABASE IF NOT EXISTS wp_video_site;" > /dev/null 2>&1
            mysql -u root -e "CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';" > /dev/null 2>&1
            mysql -u root -e "GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';" > /dev/null 2>&1
            mysql -u root -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
        fi
        success "默认数据库配置完成"
    fi
}

# 配置WordPress
configure_wordpress() {
    log "配置WordPress..."
    
    # 检查wp-site目录
    if [ ! -d "wp-site" ]; then
        error "未找到wp-site目录"
        exit 1
    fi
    
    cd wp-site
    
    # 如果wp-config.php不存在，从示例文件复制
    if [ ! -f "wp-config.php" ] && [ -f "wp-config-sample.php" ]; then
        log "创建wp-config.php文件..."
        cp wp-config-sample.php wp-config.php
    fi
    
    # 设置数据库配置
    if [ -f "wp-config.php" ]; then
        # 根据操作系统选择sed语法
        if [[ "$OS_TYPE" == "mac" ]]; then
            sed -i '' "s/database_name_here/wp_video_site/" wp-config.php
            sed -i '' "s/username_here/wp_user/" wp-config.php
            sed -i '' "s/password_here/wp_password/" wp-config.php
            sed -i '' "s/localhost/localhost/" wp-config.php
        else
            sed -i "s/database_name_here/wp_video_site/" wp-config.php
            sed -i "s/username_here/wp_user/" wp-config.php
            sed -i "s/password_here/wp_password/" wp-config.php
            sed -i "s/localhost/localhost/" wp-config.php
        fi
        
        # 添加安全密钥
        log "添加安全密钥..."
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ > wp-keys.tmp
        # 根据操作系统选择sed语法
        if [[ "$OS_TYPE" == "mac" ]]; then
            sed -i '' '/#@+/,/#@-/c\
#@+\
'"$(cat wp-keys.tmp)"'\
#@-' wp-config.php
        else
            sed -i '/#@+/,/#@-/c\#@+\'"$(cat wp-keys.tmp)"'\n#@-' wp-config.php
        fi
        rm wp-keys.tmp
    fi
    
    # 返回上级目录
    cd ..
    
    success "WordPress配置完成"
}

# 设置文件权限
set_permissions() {
    log "设置文件权限..."
    
    # 根据操作系统设置不同的用户组
    if [[ "$OS_TYPE" == "mac" ]]; then
        chown -R $CURRENT_USER:staff wp-site
    else
        chown -R www-data:www-data wp-site
    fi
    
    find wp-site -type d -exec chmod 755 {} \;
    find wp-site -type f -exec chmod 644 {} \;
    
    # 特殊权限设置
    if [ -f "wp-site/wp-config.php" ]; then
        chmod 600 wp-site/wp-config.php
    fi
    
    success "文件权限设置完成"
}

# 配置Apache虚拟主机（Mac专用）
configure_apache_mac() {
    log "配置Apache虚拟主机（Mac）..."
    
    # 获取当前目录路径
    local deploy_path=$(pwd)
    
    # 创建Apache配置文件（Mac上的路径）
    local apache_conf_dir="/etc/apache2/users"
    local user_conf_file="$apache_conf_dir/$CURRENT_USER.conf"
    
    # 检查并创建用户配置目录
    if [ ! -d "$apache_conf_dir" ]; then
        sudo mkdir -p "$apache_conf_dir"
    fi
    
    # 创建用户特定的Apache配置文件
    cat > "/tmp/$CURRENT_USER-wordpress.conf" <<EOF
# WordPress视频网站配置
<Directory "$deploy_path/wp-site">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
</Directory>

Alias /wordpress "$deploy_path/wp-site"

<Directory "$deploy_path/wp-site">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Require all granted
</Directory>
EOF

    # 将配置文件复制到Apache用户目录
    sudo cp "/tmp/$CURRENT_USER-wordpress.conf" "$user_conf_file"
    sudo chown root:wheel "$user_conf_file"
    sudo chmod 644 "$user_conf_file"
    
    # 启用必要的Apache模块和配置
    sudo sed -i '' 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf
    sudo sed -i '' 's/#LoadModule php_module/LoadModule php_module/' /etc/apache2/httpd.conf
    sudo sed -i '' 's/#Include.*users\//Include \/etc\/apache2\/users\//' /etc/apache2/httpd.conf
    
    # 重启Apache
    sudo apachectl restart > /dev/null 2>&1
    
    success "Apache配置完成（Mac）"
}

# 配置Apache虚拟主机（Linux专用）
configure_apache_linux() {
    log "配置Apache虚拟主机（Linux）..."
    
    # 获取当前目录路径
    local deploy_path=$(pwd)
    
    # 创建Apache配置文件
    cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $deploy_path/wp-site
    ServerName your-domain.com  # 请替换为您的域名
    
    <Directory $deploy_path/wp-site>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    # 启用站点和模块
    a2dissite 000-default.conf > /dev/null 2>&1
    a2ensite wordpress.conf > /dev/null 2>&1
    a2enmod rewrite > /dev/null 2>&1
    
    # 重启Apache
    systemctl reload apache2 > /dev/null 2>&1
    
    success "Apache配置完成（Linux）"
}

# 配置Apache虚拟主机（根据操作系统）
configure_apache() {
    if [[ "$OS_TYPE" == "mac" ]]; then
        configure_apache_mac
    else
        configure_apache_linux
    fi
}

# 显示访问信息
show_access_info() {
    echo ""
    success "WordPress视频网站部署完成！"
    echo ""
    log "部署路径: $(pwd)"
    log "网站目录: $(pwd)/wp-site"
    log ""
    if [[ "$OS_TYPE" == "mac" ]]; then
        log "请访问以下URL查看您的网站："
        log "  http://localhost/wordpress"
        log ""
        log "注意："
        log "1. 确保Apache服务正在运行"
        log "2. 如果遇到权限问题，请检查系统偏好设置中的安全性与隐私设置"
    else
        log "请访问以下URL查看您的网站："
        log "  http://your-server-ip"
        log ""
        log "注意："
        log "1. 请将Apache配置文件中的域名替换为您的实际域名"
        log "2. 建议在生产环境中配置SSL证书"
    fi
    log "3. 数据库信息："
    log "   数据库名: wp_video_site"
    log "   用户名: wp_user"
    log "   密码: wp_password"
    log "   主机: localhost"
}

# 主部署函数
main_deploy() {
    echo "========================================="
    echo "   WordPress视频网站跨平台部署脚本"
    echo "========================================="
    echo ""
    
    detect_os
    check_root
    check_prerequisites
    start_mysql
    configure_database
    configure_wordpress
    set_permissions
    configure_apache
    show_access_info
}

# 显示使用方法
show_usage() {
    echo "WordPress视频网站跨平台部署脚本"
    echo "================================="
    echo ""
    echo "此脚本支持Linux和Mac系统"
    echo ""
    echo "使用方法:"
    echo "  Linux系统: sudo bash deploy-universal.sh"
    echo "  Mac系统:   bash deploy-universal.sh"
    echo ""
    echo "前提条件:"
    echo "  Linux系统需要root权限"
    echo "  Mac系统需要安装Homebrew和必要软件包："
    echo "    brew install git mysql php httpd"
    echo ""
    echo "部署步骤:"
    echo "  1. 克隆代码仓库"
    echo "  2. 进入项目目录"
    echo "  3. 运行此脚本"
    echo ""
    echo "示例:"
    echo "  git clone https://github.com/your-username/your-repo.git"
    echo "  cd your-repo"
    echo "  Linux: sudo bash deploy-universal.sh"
    echo "  Mac:   bash deploy-universal.sh"
}

# 如果提供了-help参数，则显示使用方法
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# 执行主部署函数
main_deploy