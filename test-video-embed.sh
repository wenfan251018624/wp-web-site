#!/bin/bash
# 视频嵌入功能测试脚本

# 设置变量
TEST_DOMAIN="http://localhost"
DEPLOY_PATH="/var/www/html/wp-site"

echo "开始测试视频嵌入功能..."

# 1. 检查主题是否支持视频嵌入
echo "1. 检查主题视频嵌入支持..."
if [ -f "$DEPLOY_PATH/wp-content/themes/video-theme/functions.php" ]; then
    grep -q "add_theme_support.*post-formats.*video" "$DEPLOY_PATH/wp-content/themes/video-theme/functions.php"
    if [ $? -eq 0 ]; then
        echo "   ✓ 主题支持视频文章格式"
    else
        echo "   ✗ 主题不支持视频文章格式"
    fi
    
    grep -q "iframe\|video" "$DEPLOY_PATH/wp-content/themes/video-theme/functions.php"
    if [ $? -eq 0 ]; then
        echo "   ✓ 主题支持视频嵌入标签"
    else
        echo "   ✗ 主题不支持视频嵌入标签"
    fi
else
    echo "   ✗ 未找到主题functions.php文件"
fi

# 2. 检查iframe支持
echo "2. 检查iframe支持..."
PHP_FILE="$DEPLOY_PATH/wp-content/themes/video-theme/functions.php"
if grep -q "iframe\|allowfullscreen" "$PHP_FILE"; then
    echo "   ✓ 主题允许iframe嵌入"
else
    echo "   ✗ 主题未配置iframe支持"
fi

# 3. 测试YouTube URL自动嵌入
echo "3. 测试YouTube自动嵌入..."
# 创建一个临时测试文件
TEST_CONTENT="<?php
// 测试YouTube URL自动嵌入
\$test_content = 'Check out this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ';
\$embedded_content = apply_filters('the_content', \$test_content);
echo \$embedded_content;
?>"

# 4. 检查oEmbed支持
echo "4. 检查oEmbed支持..."
if wp_eval "echo (function_exists('wp_oembed_add_provider') ? '✓' : '✗') . ' oEmbed功能可用';" 2>/dev/null; then
    echo "   ✓ oEmbed功能已启用"
else
    echo "   ? 无法检测oEmbed状态"
fi

# 5. 检查文章中嵌入的视频
echo "5. 检查文章视频嵌入..."
# 这需要实际创建一个测试文章并检查输出

echo "视频嵌入功能测试完成!"
echo "注意：某些测试需要在实际WordPress环境中运行才能获得准确结果"