#!/bin/bash
# VPS服务器初始化脚本
# 用于安装部署WordPress所需的必要软件包

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
        error "请使用 'sudo bash vps-setup.sh' 命令运行"
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
        
        # 检查是否为Ubuntu/Debian系统
        if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
            success "支持的操作系统"
        else
            warning "此脚本主要针对Ubuntu/Debian系统设计"
        fi
    else
        error "无法检测操作系统类型"
        exit 1
    fi
}

# 更新系统包
update_system() {
    log "更新系统包..."
    apt update -y > /dev/null 2>&1
    success "系统包更新完成"
}

# 安装必要的软件包
install_packages() {
    log "安装必要的软件包..."
    
    # 安装Git
    if ! command -v git &> /dev/null; then
        log "安装Git..."
        apt install git -y > /dev/null 2>&1
        success "Git安装完成"
    else
        success "Git已安装"
    fi
    
    # 安装Apache
    if ! command -v apache2 &> /dev/null; then
        log "安装Apache..."
        apt install apache2 -y > /dev/null 2>&1
        success "Apache安装完成"
    else
        success "Apache已安装"
    fi
    
    # 安装MySQL
    if ! command -v mysql &> /dev/null; then
        log "安装MySQL..."
        apt install mysql-server -y > /dev/null 2>&1
        success "MySQL安装完成"
    else
        success "MySQL已安装"
    fi
    
    # 安装PHP及相关模块
    if ! command -v php &> /dev/null; then
        log "安装PHP及相关模块..."
        apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y > /dev/null 2>&1
        success "PHP及相关模块安装完成"
    else
        success "PHP已安装"
    fi
}

# 启动并启用服务
enable_services() {
    log "启动并启用系统服务..."
    
    # 启动Apache
    systemctl start apache2 > /dev/null 2>&1
    systemctl enable apache2 > /dev/null 2>&1
    
    # 启动MySQL
    systemctl start mysql > /dev/null 2>&1
    systemctl enable mysql > /dev/null 2>&1
    
    success "系统服务已启动并设置为开机自启"
}

# 配置MySQL安全设置
configure_mysql() {
    log "配置MySQL安全设置..."
    
    # 设置MySQL root密码（如果尚未设置）
    # 注意：在生产环境中，您应该使用更安全的密码
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';" > /dev/null 2>&1
    mysql -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
    
    success "MySQL安全设置完成"
}

# 主函数
main() {
    echo "========================================="
    echo "        VPS服务器初始化脚本"
    echo "========================================="
    echo ""
    
    check_root
    check_os
    update_system
    install_packages
    enable_services
    configure_mysql
    
    echo ""
    success "VPS服务器初始化完成！"
    echo ""
    log "下一步，请克隆您的代码仓库："
    log "git clone https://github.com/wenfan251018624/wp-web-site.git"
    log "然后进入项目目录并运行部署脚本："
    log "cd wp-web-site && sudo bash deploy.sh"
}

# 执行主函数
main