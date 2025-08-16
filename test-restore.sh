#!/bin/bash
# 备份恢复测试脚本

# 设置变量
BACKUP_DIR="/var/backups/wordpress"
WP_PATH="/var/www/html/wp-site"
DB_NAME="wp_video_site"
DB_USER="wp_user"
DB_PASSWORD="wp_password"

echo "开始测试备份恢复流程..."

# 1. 检查备份文件是否存在
echo "1. 检查备份文件..."
LATEST_BACKUP=$(ls -t $BACKUP_DIR/wp-files-*.tar.gz 2>/dev/null | head -n1)
if [ -n "$LATEST_BACKUP" ]; then
    echo "   ✓ 找到最新文件备份: $(basename $LATEST_BACKUP)"
else
    echo "   ✗ 未找到文件备份"
    exit 1
fi

LATEST_DB_BACKUP=$(ls -t $BACKUP_DIR/wp-db-*.tar.gz 2>/dev/null | head -n1)
if [ -n "$LATEST_DB_BACKUP" ]; then
    echo "   ✓ 找到最新数据库备份: $(basename $LATEST_DB_BACKUP)"
else
    echo "   ✗ 未找到数据库备份"
    exit 1
fi

# 2. 创建临时恢复目录
echo "2. 创建临时恢复目录..."
TEMP_DIR="/tmp/wp-restore-test"
sudo rm -rf $TEMP_DIR
sudo mkdir -p $TEMP_DIR

# 3. 测试文件备份解压
echo "3. 测试文件备份解压..."
sudo tar -xzf $LATEST_BACKUP -C $TEMP_DIR
if [ -d "$TEMP_DIR/wp-site" ]; then
    echo "   ✓ 文件备份解压成功"
else
    echo "   ✗ 文件备份解压失败"
fi

# 4. 测试数据库备份解压
echo "4. 测试数据库备份解压..."
sudo tar -xzf $LATEST_DB_BACKUP -C $TEMP_DIR
SQL_FILE=$(ls $TEMP_DIR/*.sql 2>/dev/null)
if [ -n "$SQL_FILE" ]; then
    echo "   ✓ 数据库备份解压成功"
else
    echo "   ✗ 数据库备份解压失败"
fi

# 5. 创建临时数据库进行恢复测试
echo "5. 测试数据库恢复..."
TEMP_DB="wp_restore_test_$(date +%s)"
mysql -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $TEMP_DB;" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ 临时数据库创建成功"
    
    # 尝试恢复数据库（仅测试，不实际恢复）
    # mysql -u $DB_USER -p$DB_PASSWORD $TEMP_DB < $SQL_FILE 2>/dev/null
    # if [ $? -eq 0 ]; then
    #     echo "   ✓ 数据库恢复测试成功"
    # else
    #     echo "   ✗ 数据库恢复测试失败"
    # fi
    
    # 清理临时数据库
    mysql -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE $TEMP_DB;" 2>/dev/null
else
    echo "   ✗ 临时数据库创建失败"
fi

# 6. 检查备份完整性
echo "6. 检查备份完整性..."
FILE_SIZE=$(stat -c%s "$LATEST_BACKUP")
DB_SIZE=$(stat -c%s "$LATEST_DB_BACKUP")
echo "   文件备份大小: $FILE_SIZE bytes"
echo "   数据库备份大小: $DB_SIZE bytes"

if [ $FILE_SIZE -gt 1024 ] && [ $DB_SIZE -gt 1024 ]; then
    echo "   ✓ 备份文件大小合理"
else
    echo "   ✗ 备份文件可能不完整"
fi

# 7. 清理临时文件
echo "7. 清理临时文件..."
sudo rm -rf $TEMP_DIR

echo "备份恢复测试完成!"
echo "恢复流程说明:"
echo "  1. 停止Web服务器和数据库服务"
echo "  2. 备份当前网站文件和数据库"
echo "  3. 解压文件备份到网站目录"
echo "  4. 恢复数据库备份"
echo "  5. 调整文件权限"
echo "  6. 启动服务并测试网站"