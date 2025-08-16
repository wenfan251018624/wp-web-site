#!/bin/bash
# 智能本地开发环境启动脚本
# 自动检测可用环境并选择最佳启动方式

echo "WordPress视频网站开发环境启动器"
echo "================================"
echo ""

# 检查Docker是否可用
check_docker() {
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            echo "✅ Docker: 可用"
            return 0
        else
            echo "⚠️  Docker: 已安装但未运行"
            return 1
        fi
    else
        echo "❌ Docker: 未安装"
        return 1
    fi
}

# 检查PHP是否可用
check_php() {
    if command -v php &> /dev/null; then
        echo "✅ PHP: $(php --version | head -n1 | cut -d' ' -f1,2)"
        return 0
    else
        echo "❌ PHP: 未安装"
        return 1
    fi
}

# 检查网站目录
check_site_directory() {
    if [ -d "./wp-site" ]; then
        echo "✅ 网站目录: 已找到"
        return 0
    else
        echo "❌ 网站目录: 未找到"
        return 1
    fi
}

echo "环境检查:"
echo "----------"

# 执行检查
check_site_directory
SITE_CHECK=$?

DOCKER_AVAILABLE=0
PHP_AVAILABLE=0

if check_docker; then
    DOCKER_AVAILABLE=1
fi

if check_php; then
    PHP_AVAILABLE=1
fi

echo ""

# 根据检查结果选择启动方式
if [ $SITE_CHECK -eq 0 ]; then
    if [ $DOCKER_AVAILABLE -eq 0 ]; then
        echo "推荐使用Docker启动 (最简单的方式)"
        echo "================================"
        echo "1. 请确保Docker Desktop正在运行"
        echo "2. 运行以下命令启动:"
        echo "   ./start-with-docker.sh"
        echo ""
        echo "访问地址: http://localhost:8080"
    elif [ $PHP_AVAILABLE -eq 0 ]; then
        echo "推荐使用PHP内置服务器启动"
        echo "=========================="
        echo "运行以下命令启动:"
        echo "   ./test-local.sh"
        echo ""
        echo "访问地址: http://localhost:8080"
    else
        echo "需要安装开发环境"
        echo "================"
        echo "请参考以下文档安装开发环境:"
        echo "  - QUICK_START.md: 快速设置指南"
        echo "  - LOCAL_DEVELOPMENT_SETUP.md: 详细设置说明"
        echo "  - DOCKER_DEVELOPMENT.md: Docker环境设置"
        echo ""
        echo "建议首选Docker方式，最简单且环境一致"
    fi
else
    echo "❌ 错误: 未找到网站目录"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

echo ""
echo "帮助文档:"
echo "---------"
echo "📖 DOCKER_DEVELOPMENT.md - Docker开发环境详细说明"
echo "📖 QUICK_START.md - 快速开始指南"
echo "📖 LOCAL_DEVELOPMENT_SETUP.md - 本地环境详细设置"