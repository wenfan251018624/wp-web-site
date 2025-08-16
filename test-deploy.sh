#!/bin/bash
# 部署流程测试脚本

# 设置变量
TEST_DOMAIN="http://localhost"
DEPLOY_PATH="/var/www/html/wp-site"

echo "开始测试部署流程..."

# 1. 检查Web服务器是否运行
echo "1. 检查Apache状态..."
if systemctl is-active --quiet apache2; then
    echo "   ✓ Apache正在运行"
else
    echo "   ✗ Apache未运行"
    exit 1
fi

# 2. 检查MySQL是否运行
echo "2. 检查MySQL状态..."
if systemctl is-active --quiet mysql; then
    echo "   ✓ MySQL正在运行"
else
    echo "   ✗ MySQL未运行"
    exit 1
fi

# 3. 检查WordPress文件是否存在
echo "3. 检查WordPress文件..."
if [ -f "$DEPLOY_PATH/wp-config.php" ]; then
    echo "   ✓ wp-config.php存在"
else
    echo "   ✗ wp-config.php不存在"
fi

if [ -d "$DEPLOY_PATH/wp-content" ]; then
    echo "   ✓ wp-content目录存在"
else
    echo "   ✗ wp-content目录不存在"
fi

# 4. 检查主题是否存在
echo "4. 检查主题..."
if [ -d "$DEPLOY_PATH/wp-content/themes/video-theme" ]; then
    echo "   ✓ 自定义视频主题存在"
else
    echo "   ✗ 自定义视频主题不存在"
fi

# 5. 测试数据库连接
echo "5. 测试数据库连接..."
mysql -u wp_user -pwp_password -e "USE wp_video_site; SHOW TABLES;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ 数据库连接成功"
else
    echo "   ✗ 数据库连接失败"
fi

# 6. 测试网站访问
echo "6. 测试网站访问..."
curl -s --head $TEST_DOMAIN | head -n 1 | grep "200\|301\|302" > /dev/null
if [ $? -eq 0 ]; then
    echo "   ✓ 网站可访问"
else
    echo "   ✗ 网站无法访问"
fi

# 7. 检查Git状态
echo "7. 检查Git仓库状态..."
cd $DEPLOY_PATH
if git status > /dev/null 2>&1; then
    echo "   ✓ Git仓库正常"
else
    echo "   ✗ Git仓库异常"
fi

echo "部署流程测试完成!"