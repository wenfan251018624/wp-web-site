#!/bin/bash
# 使用Docker启动WordPress开发环境

echo "WordPress Docker开发环境启动器"
echo "=============================="
echo ""

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未找到Docker"
    echo "请先安装Docker Desktop for Mac:"
    echo "  https://www.docker.com/products/docker-desktop/"
    echo ""
    echo "安装完成后重新运行此脚本"
    exit 1
fi

# 检查docker-compose是否可用
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  警告: 未找到docker-compose命令"
    echo "尝试使用 'docker compose' 替代..."
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
fi

echo "✅ Docker版本: $(docker --version)"
echo ""

# 检查必要的目录是否存在
if [ ! -d "./wp-site" ]; then
    echo "❌ 错误: wp-site 目录不存在"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

echo "正在启动WordPress开发环境..."
echo "这可能需要几分钟时间来下载必要的Docker镜像..."
echo ""

# 启动Docker环境
$DOCKER_COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    echo "✅ Docker环境启动成功!"
    echo ""
    echo "WordPress现在可以通过以下URL访问:"
    echo "  http://localhost:8080"
    echo ""
    echo "MySQL数据库信息:"
    echo "  主机: localhost:3306"
    echo "  数据库名: wp_video_site"
    echo "  用户名: wp_user"
    echo "  密码: wp_password"
    echo ""
    echo "管理命令:"
    echo "  停止环境: $DOCKER_COMPOSE_CMD down"
    echo "  查看日志: $DOCKER_COMPOSE_CMD logs"
    echo "  重启环境: $DOCKER_COMPOSE_CMD restart"
else
    echo "❌ Docker环境启动失败"
    echo "请检查错误信息并尝试解决问题"
fi