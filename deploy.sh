#!/bin/bash
# 一键部署脚本 - WordPress视频网站
# 优化版本，可直接从git clone后的环境运行

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

# 显示使用说明
show_usage() {
    echo "WordPress视频网站一键部署脚本"
    echo "=============================="
    echo "使用方法:"
    echo "  bash deploy.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -i, --install  执行完整安装部署"
    echo "  -u, --update   更新现有部署"
    echo ""
    echo "说明:"
    echo "  此脚本可以直接从git clone后的环境中运行"
    echo "  默认情况下，脚本会检查系统环境并自动安装所需组件"
    echo ""
    echo "示例:"
    echo "  bash deploy.sh              # 显示帮助信息"
    echo "  bash deploy.sh --install    # 执行完整安装"
    echo "  bash deploy.sh --update     # 更新现有部署"
}

# 检查root权限
check_root() {
    if [[ $EUID -eq 0 ]]; then
        success "以root权限运行"
        return 0
    else
        warning "未以root权限运行，将尝试使用sudo"
        return 1
    fi
}

# 检查系统类型
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log "检测到操作系统: $OS $VER"
        
        # 检查是否为Ubuntu/Debian系统
        if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
            success "支持的操作系统"
            return 0
        else
            warning "可能不完全支持的操作系统: $OS"
            return 1
        fi
    else
        error "无法检测操作系统类型"
        return 1
    fi
}

# 检查并安装必要软件包
check_and_install_packages() {
    log "检查并安装必要的软件包..."
    
    # 更新包列表
    log "更新包列表..."
    if command -v apt &> /dev/null; then
        if check_root; then
            apt update -y > /dev/null 2>&1
        else
            sudo apt update -y > /dev/null 2>&1
        fi
    else
        error "不支持的包管理器，仅支持基于Debian/Ubuntu的系统"
        return 1
    fi
    
    # 检查必要软件包
    packages=("git" "apache2" "mysql-server" "php" "libapache2-mod-php" "php-mysql")
    missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            missing_packages+=($package)
        fi
    done
    
    # 安装缺失的软件包
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log "安装缺失的软件包: ${missing_packages[*]}"
        if check_root; then
            apt install ${missing_packages[*]} -y > /dev/null 2>&1
        else
            sudo apt install ${missing_packages[*]} -y > /dev/null 2>&1
        fi
        success "软件包安装完成"
    else
        success "所有必要软件包已安装"
    fi
}

# 启动并启用服务
enable_services() {
    log "启动并启用系统服务..."
    
    services=("apache2" "mysql")
    for service in "${services[@]}"; do
        log "启动并启用 $service 服务..."
        if check_root; then
            systemctl start $service > /dev/null 2>&1
            systemctl enable $service > /dev/null 2>&1
        else
            sudo systemctl start $service > /dev/null 2>&1
            sudo systemctl enable $service > /dev/null 2>&1
        fi
    done
    
    success "系统服务已启动并设置为开机自启"
}

# 配置MySQL数据库
configure_mysql() {
    log "配置MySQL数据库..."
    
    # 创建WordPress数据库和用户
    mysql_commands="
    CREATE DATABASE IF NOT EXISTS wp_video_site;
    CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
    GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
    FLUSH PRIVILEGES;"
    
    if check_root; then
        echo "$mysql_commands" | mysql -u root > /dev/null 2>&1
    else
        echo "$mysql_commands" | sudo mysql -u root > /dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        success "MySQL数据库配置完成"
    else
        error "MySQL数据库配置失败"
        return 1
    fi
}

# 配置WordPress
configure_wordpress() {
    local wp_path=$(pwd)
    
    log "配置WordPress..."
    
    # 如果wp-config.php不存在，从示例文件复制
    if [ ! -f "wp-config.php" ] && [ -f "wp-config-sample.php" ]; then
        cp wp-config-sample.php wp-config.php
        success "创建wp-config.php文件"
    fi
    
    # 设置数据库配置
    if [ -f "wp-config.php" ]; then
        sed -i "s/database_name_here/wp_video_site/" wp-config.php
        sed -i "s/username_here/wp_user/" wp-config.php
        sed -i "s/password_here/wp_password/" wp-config.php
        sed -i "s/localhost/localhost/" wp-config.php
        
        # 添加安全密钥（如果还没有）
        if ! grep -q "put your unique phrase here" wp-config.php; then
            log "安全密钥已存在"
        else
            curl -s https://api.wordpress.org/secret-key/1.1/salt/ > wp-keys.tmp
            sed -i '/#@+/,/#@-/c\#@+\'"$(cat wp-keys.tmp)"'\n#@-' wp-config.php
            rm wp-keys.tmp
            success "添加安全密钥"
        fi
        
        # 设置文件权限
        if check_root; then
            chown www-data:www-data wp-config.php
        else
            sudo chown www-data:www-data wp-config.php
        fi
        chmod 600 wp-config.php
        
        success "WordPress配置完成"
    else
        error "wp-config.php文件不存在，无法配置WordPress"
        return 1
    fi
}

# 设置文件权限
set_permissions() {
    local site_path=$(pwd)
    
    log "设置文件权限..."
    
    if check_root; then
        chown -R www-data:www-data "$site_path"
        find "$site_path" -type d -exec chmod 755 {} \;
        find "$site_path" -type f -exec chmod 644 {} \;
    else
        sudo chown -R www-data:www-data "$site_path"
        sudo find "$site_path" -type d -exec chmod 755 {} \;
        sudo find "$site_path" -type f -exec chmod 644 {} \;
    fi
    
    success "文件权限设置完成"
}

# 配置Apache虚拟主机
configure_apache() {
    local site_path=$(pwd)
    
    log "配置Apache虚拟主机..."
    
    # 创建Apache配置文件
    apache_config="
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $site_path
    ServerName localhost
    
    <Directory $site_path>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \\\${APACHE_LOG_DIR}/error.log
    CustomLog \\\${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"
    
    if check_root; then
        echo "$apache_config" > /etc/apache2/sites-available/wordpress.conf
    else
        echo "$apache_config" | sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null
    fi
    
    # 禁用默认站点，启用WordPress站点
    if check_root; then
        a2dissite 000-default.conf > /dev/null 2>&1
        a2ensite wordpress.conf > /dev/null 2>&1
        a2enmod rewrite > /dev/null 2>&1
        systemctl reload apache2 > /dev/null 2>&1
    else
        sudo a2dissite 000-default.conf > /dev/null 2>&1
        sudo a2ensite wordpress.conf > /dev/null 2>&1
        sudo a2enmod rewrite > /dev/null 2>&1
        sudo systemctl reload apache2 > /dev/null 2>&1
    fi
    
    success "Apache配置完成"
}

# 安装部署函数
install_deploy() {
    log "开始完整安装部署..."
    
    check_os || return 1
    check_and_install_packages || return 1
    enable_services || return 1
    configure_mysql || return 1
    configure_wordpress || return 1
    set_permissions || return 1
    configure_apache || return 1
    
    success "WordPress视频网站安装部署完成！"
    log "请访问 http://your-server-ip 查看网站"
    log "建议在生产环境中修改默认的数据库密码"
}

# 更新部署函数
update_deploy() {
    log "更新现有部署..."
    
    # 拉取最新代码
    if [ -d ".git" ]; then
        log "拉取最新代码..."
        if check_root; then
            sudo -u www-data git pull > /dev/null 2>&1
        else
            sudo sudo -u www-data git pull > /dev/null 2>&1
        fi
        success "代码更新完成"
    else
        warning "当前目录不是git仓库，跳过代码更新"
    fi
    
    # 重新配置WordPress（如果需要）
    configure_wordpress
    
    # 重新设置权限
    set_permissions
    
    # 重启Apache
    log "重启Apache服务..."
    if check_root; then
        systemctl reload apache2 > /dev/null 2>&1
    else
        sudo systemctl reload apache2 > /dev/null 2>&1
    fi
    
    success "更新部署完成！"
}

# 主函数
main() {
    # 检查参数
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -i|--install)
            install_deploy
            ;;
        -u|--update)
            update_deploy
            ;;
        "")
            show_usage
            exit 0
            ;;
        *)
            error "未知参数: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"