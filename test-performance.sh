#!/bin/bash
# 网站性能测试脚本

# 设置变量
TEST_URL="http://localhost"
DEPLOY_PATH="/var/www/html/wp-site"

echo "开始测试网站性能..."

# 1. 安装性能测试工具（如果需要）
echo "1. 检查性能测试工具..."
if ! command -v curl &> /dev/null; then
    echo "   安装curl..."
    sudo apt install curl -y
fi

# 2. 测试页面加载时间
echo "2. 测试页面加载时间..."
LOAD_TIME=$(curl -s -w "%{time_total}\n" -o /dev/null $TEST_URL)
echo "   页面加载时间: ${LOAD_TIME}s"

if (( $(echo "$LOAD_TIME < 2" | bc -l) )); then
    echo "   ✓ 页面加载速度优秀 (< 2s)"
elif (( $(echo "$LOAD_TIME < 5" | bc -l) )); then
    echo "   ○ 页面加载速度良好 (< 5s)"
else
    echo "   ✗ 页面加载速度较慢 (> 5s)"
fi

# 3. 测试HTTP响应状态
echo "3. 测试HTTP响应状态..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $TEST_URL)
echo "   HTTP状态码: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "   ✓ HTTP响应正常"
else
    echo "   ✗ HTTP响应异常"
fi

# 4. 检查网站大小
echo "4. 检查页面大小..."
PAGE_SIZE=$(curl -s -w "%{size_download}" $TEST_URL)
echo "   页面大小: $PAGE_SIZE bytes"

# 5. 测试数据库查询性能
echo "5. 测试数据库性能..."
DB_TEST=$(mysql -u wp_user -pwp_password -e "SELECT COUNT(*) FROM wp_posts;" wp_video_site 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   ✓ 数据库查询正常"
else
    echo "   ✗ 数据库查询异常"
fi

# 6. 检查PHP配置
echo "6. 检查PHP配置..."
PHP_MEMORY=$(php -r "echo ini_get('memory_limit');")
echo "   PHP内存限制: $PHP_MEMORY"

# 7. 检查Apache配置
echo "7. 检查Apache配置..."
if systemctl is-active --quiet apache2; then
    APACHE_PROCESSES=$(ps aux | grep apache2 | wc -l)
    echo "   Apache进程数: $APACHE_PROCESSES"
else
    echo "   ✗ Apache未运行"
fi

# 8. 检查缓存配置
echo "8. 检查缓存配置..."
if [ -f "$DEPLOY_PATH/wp-config.php" ]; then
    grep -q "WP_CACHE" "$DEPLOY_PATH/wp-config.php"
    if [ $? -eq 0 ]; then
        echo "   ✓ WP_CACHE已启用"
    else
        echo "   ○ WP_CACHE未启用"
    fi
fi

echo "性能测试完成!"
echo "建议优化项:"
echo "  - 启用页面缓存插件"
echo "  - 优化图片大小和格式"
echo "  - 使用CDN加速"
echo "  - 启用Gzip压缩"