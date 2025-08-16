#!/bin/bash
# 快速修复脚本 - 专门解决CentOS 7数据库配置问题

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志文件
LOG_FILE="/var/log/wp-deploy-fix.log"

# 日志函数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
}

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
    error "此脚本需要root权限运行"
    exit 1
fi

log "开始修复WordPress数据库配置..."

# 启动MariaDB服务
log "启动MariaDB服务..."
systemctl start mariadb > /dev/null 2>&1

# 等待服务启动
sleep 5

# 创建WordPress数据库和用户
log "创建WordPress数据库和用户..."
mysql_commands="
CREATE DATABASE IF NOT EXISTS wp_video_site;
CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;"

# 尝试多种方式连接数据库
if echo "$mysql_commands" | mysql -u root -proot_password > /dev/null 2>&1; then
    success "MySQL数据库配置完成!"
elif echo "$mysql_commands" | mysql -u root > /dev/null 2>&1; then
    success "MySQL数据库配置完成!"
else
    error "MySQL数据库配置失败"
    log "请手动执行以下命令："
    log "sudo mysql -u root"
    log "然后在MySQL中执行："
    log "$mysql_commands"
    exit 1
fi

# 重新启动Apache
log "重启Apache服务..."
systemctl restart httpd > /dev/null 2>&1

success "修复完成！请重新运行部署脚本或访问网站测试。"
log "详细日志请查看: $LOG_FILE"