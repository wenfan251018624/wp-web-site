#!/bin/bash
# WordPress数据库连接配置脚本

# 设置变量
DB_NAME="wp_video_site"
DB_USER="wp_user"
DB_PASSWORD="wp_password"
DB_HOST="localhost"
WP_PATH="/var/www/html/wp-site"

# 进入WordPress目录
cd $WP_PATH

# 检查wp-config.php是否存在
if [ ! -f "wp-config.php" ]; then
    # 如果不存在，从示例文件复制
    if [ -f "wp-config-sample.php" ]; then
        sudo cp wp-config-sample.php wp-config.php
    else
        echo "错误：找不到wp-config-sample.php文件"
        exit 1
    fi
fi

# 设置数据库配置
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" wp-config.php

# 添加安全密钥（从WordPress API获取）
sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-keys.tmp
sudo sed -i '/#@+/,/#@-/c\#@+\n'"$(cat wp-keys.tmp)"'\n#@-' wp-config.php
sudo rm wp-keys.tmp

# 设置文件权限
sudo chown www-data:www-data wp-config.php
sudo chmod 600 wp-config.php

echo "WordPress数据库连接配置完成!"