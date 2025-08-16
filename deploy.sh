#!/bin/bash
# WordPress自动部署脚本

# 设置变量
REPO_URL="https://github.com/your-username/your-repo.git"
DEPLOY_PATH="/var/www/html/wp-site"
BRANCH="main"

# 进入部署目录
cd $DEPLOY_PATH

# 检查是否已克隆仓库
if [ ! -d ".git" ]; then
    echo "克隆仓库..."
    git clone $REPO_URL .
else
    echo "拉取最新代码..."
    git pull origin $BRANCH
fi

# 安装/更新依赖（如果使用Composer）
if [ -f "composer.json" ]; then
    echo "更新PHP依赖..."
    composer install --no-dev --optimize-autoloader
fi

# 安装/更新依赖（如果使用NPM）
if [ -f "package.json" ]; then
    echo "更新Node.js依赖..."
    npm install --production
    npm run build
fi

# 设置文件权限
echo "设置文件权限..."
sudo chown -R www-data:www-data $DEPLOY_PATH
sudo find $DEPLOY_PATH -type d -exec chmod 755 {} \;
sudo find $DEPLOY_PATH -type f -exec chmod 644 {} \;

# 重启Web服务器
echo "重启Apache..."
sudo systemctl reload apache2

echo "部署完成!"