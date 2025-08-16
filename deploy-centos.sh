#!/bin/bash
# 一键部署脚本 - WordPress视频网站 (CentOS 7版本)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志文件
LOG_FILE="/var/log/wp-deploy.log"

# 日志函数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a $LOG_FILE
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
}

# 显示使用说明
show_usage() {
    echo "WordPress视频网站一键部署脚本 (CentOS 7版本)"
    echo "=============================="
    echo "使用方法:"
    echo "  bash deploy-centos.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -i, --install  执行完整安装部署"
    echo "  -u, --update   更新现有部署"
    echo ""
    echo "说明:"
    echo "  此脚本专为CentOS 7系统设计"
    echo "  脚本会检查系统环境并自动安装所需组件"
    echo ""
    echo "示例:"
    echo "  bash deploy-centos.sh              # 显示帮助信息"
    echo "  bash deploy-centos.sh --install    # 执行完整安装"
    echo "  bash deploy-centos.sh --update     # 更新现有部署"
}

# 检查root权限
check_root() {
    if [[ $EUID -eq 0 ]]; then
        success "以root权限运行"
        return 0
    else
        error "此脚本需要root权限运行"
        error "请使用 'sudo bash deploy-centos.sh' 命令运行"
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
        
        # 检查是否为CentOS 7
        if [[ "$OS" == *"CentOS"* ]] && [[ "$VER" == *"7"* ]]; then
            success "支持的操作系统: CentOS 7"
            return 0
        else
            error "不支持的操作系统: $OS $VER"
            error "此脚本仅支持CentOS 7"
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
    yum update -y > /dev/null 2>&1
    
    # 检查必要软件包
    packages=("git" "httpd" "mariadb-server" "php" "php-mysql" "php-gd" "php-xml" "php-mbstring")
    missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! rpm -q $package > /dev/null 2>&1; then
            missing_packages+=($package)
        fi
    done
    
    # 安装缺失的软件包
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log "安装缺失的软件包: ${missing_packages[*]}"
        yum install ${missing_packages[*]} -y > /dev/null 2>&1
        success "软件包安装完成"
    else
        success "所有必要软件包已安装"
    fi
}

# 启动并启用服务
enable_services() {
    log "启动并启用系统服务..."
    
    services=("httpd" "mariadb")
    for service in "${services[@]}"; do
        log "启动并启用 $service 服务..."
        systemctl start $service > /dev/null 2>&1
        systemctl enable $service > /dev/null 2>&1
    done
    
    success "系统服务已启动并设置为开机自启"
}

# 配置MySQL数据库
configure_mysql() {
    log "配置MySQL数据库..."
    
    # 启动MySQL服务
    systemctl start mariadb > /dev/null 2>&1
    
    # 首先尝试不使用密码连接root用户来设置密码
    log "设置MySQL root密码..."
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root_password';
FLUSH PRIVILEGES;
EOF
    
    # 如果上面失败，尝试使用mysql_secure_installation
    if [ $? -ne 0 ]; then
        log "运行MySQL安全配置..."
        mysql_secure_installation <<EOF

y
root_password
root_password
y
y
y
y
EOF
    fi
    
    # 创建WordPress数据库和用户
    log "创建WordPress数据库和用户..."
    mysql_commands="
    CREATE DATABASE IF NOT EXISTS wp_video_site;
    CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
    GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
    FLUSH PRIVILEGES;"
    
    # 尝试使用root密码连接
    if echo "$mysql_commands" | mysql -u root -proot_password > /dev/null 2>&1; then
        success "MySQL数据库配置完成"
    else
        # 如果使用密码失败，尝试不使用密码（某些配置下可能有效）
        if echo "$mysql_commands" | mysql -u root > /dev/null 2>&1; then
            success "MySQL数据库配置完成"
        else
            error "MySQL数据库配置失败"
            log "请手动检查MariaDB配置"
            return 1
        fi
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
        chown apache:apache wp-config.php
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
    
    chown -R apache:apache "$site_path"
    find "$site_path" -type d -exec chmod 755 {} \;
    find "$site_path" -type f -exec chmod 644 {} \;
    
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
    
    echo "$apache_config" > /etc/httpd/conf.d/wordpress.conf
    
    # 重启Apache
    systemctl restart httpd > /dev/null 2>&1
    
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
        sudo -u apache git pull > /dev/null 2>&1
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
    systemctl restart httpd > /dev/null 2>&1
    
    success "更新部署完成！"
}

# 主函数
main() {
    check_root
    
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