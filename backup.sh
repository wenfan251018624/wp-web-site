#!/bin/bash
# WordPress定期备份脚本

# 设置变量
BACKUP_DIR="/var/backups/wordpress"
WP_PATH="/var/www/html/wp-site"
DB_NAME="wp_video_site"
DB_USER="wp_user"
DB_PASSWORD="wp_password"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# 创建备份目录
sudo mkdir -p $BACKUP_DIR

# 备份WordPress文件
sudo tar -czf $BACKUP_DIR/wp-files-$DATE.tar.gz -C /var/www/html wp-site

# 备份数据库
sudo mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/wp-db-$DATE.sql
sudo tar -czf $BACKUP_DIR/wp-db-$DATE.tar.gz -C $BACKUP_DIR wp-db-$DATE.sql
sudo rm $BACKUP_DIR/wp-db-$DATE.sql

# 设置备份文件权限
sudo chown root:root $BACKUP_DIR/wp-*
sudo chmod 600 $BACKUP_DIR/wp-*

# 删除过期备份（保留最近30天）
sudo find $BACKUP_DIR -name "wp-*" -mtime +$RETENTION_DAYS -delete

# 验证备份
if [ -f "$BACKUP_DIR/wp-files-$DATE.tar.gz" ] && [ -f "$BACKUP_DIR/wp-db-$DATE.tar.gz" ]; then
    echo "备份成功完成: $DATE"
    echo "文件备份: $BACKUP_DIR/wp-files-$DATE.tar.gz"
    echo "数据库备份: $BACKUP_DIR/wp-db-$DATE.tar.gz"
else
    echo "备份失败!"
    exit 1
fi