#!/bin/bash
# 简化版本地测试脚本

echo "WordPress本地测试启动器"
echo "========================"
echo ""

# 检查PHP是否可用
if ! command -v php &> /dev/null; then
    echo "⚠️  警告: 未找到PHP"
    echo "请先安装PHP，可以通过以下命令安装:"
    echo "  brew install php@8.2"
    echo ""
    echo "或参考 QUICK_START.md 获取完整的本地开发环境设置指南"
    exit 1
fi

# 检查网站目录是否存在
SITE_DIR="/Users/yanwu/Documents/severs/wp-web-site/wp-site"
if [ ! -d "$SITE_DIR" ]; then
    echo "❌ 错误: 网站目录不存在"
    echo "请确认 $SITE_DIR 目录存在"
    exit 1
fi

echo "✅ PHP版本: $(php --version | head -n1)"
echo "✅ 网站目录: $SITE_DIR"
echo ""

# 启动PHP内置服务器
echo "启动PHP内置服务器..."
echo "请在浏览器中访问: http://localhost:8080"
echo "按 Ctrl+C 停止服务器"
echo ""

cd "$SITE_DIR"
php -S localhost:8080