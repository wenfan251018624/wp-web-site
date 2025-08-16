#!/bin/bash
# 在VPS上克隆GitHub仓库的脚本

# 设置变量
GITHUB_REPO="https://github.com/your-username/your-repo.git"  # 请替换为您的实际仓库URL
INSTALL_PATH="/var/www/html/wp-site"
BRANCH="main"

# 更新系统包
sudo apt update

# 安装Git（如果尚未安装）
sudo apt install git -y

# 创建安装目录
sudo mkdir -p $INSTALL_PATH

# 设置目录权限
sudo chown www-data:www-data $INSTALL_PATH

# 克隆仓库
echo "克隆GitHub仓库..."
sudo -u www-data git clone $GITHUB_REPO $INSTALL_PATH

# 进入项目目录
cd $INSTALL_PATH

# 切换到指定分支
sudo -u www-data git checkout $BRANCH

# 设置Git配置
sudo -u www-data git config user.name "VPS Server"
sudo -u www-data git config user.email "server@your-domain.com"

echo "仓库克隆完成!"