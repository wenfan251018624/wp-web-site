#!/bin/bash
# WordPress安全设置检查脚本

# 设置变量
WP_PATH="/var/www/html/wp-site"
LOG_FILE="/var/log/wp-security.log"

echo "开始检查WordPress安全设置..."

# 1. 检查wp-config.php权限
echo "1. 检查wp-config.php权限..."
if [ -f "$WP_PATH/wp-config.php" ]; then
    WP_CONFIG_PERMS=$(stat -c %a "$WP_PATH/wp-config.php")
    if [ "$WP_CONFIG_PERMS" = "600" ]; then
        echo "   ✓ wp-config.php权限正确 (600)"
    else
        echo "   ✗ wp-config.php权限不安全 ($WP_CONFIG_PERMS)"
    fi
else
    echo "   ✗ wp-config.php不存在"
fi

# 2. 检查WordPress版本
echo "2. 检查WordPress版本..."
if [ -f "$WP_PATH/wp-includes/version.php" ]; then
    WP_VERSION=$(grep "wp_version =" "$WP_PATH/wp-includes/version.php" | cut -d"'" -f2)
    echo "   WordPress版本: $WP_VERSION"
    # 这里可以添加版本检查逻辑
else
    echo "   ✗ 无法确定WordPress版本"
fi

# 3. 检查默认用户名
echo "3. 检查默认用户名..."
# 这需要数据库访问权限来检查

# 4. 检查文件权限
echo "4. 检查文件权限..."
DIR_PERMS=$(stat -c %a "$WP_PATH")
if [ "$DIR_PERMS" = "755" ] || [ "$DIR_PERMS" = "750" ]; then
    echo "   ✓ 目录权限合理 ($DIR_PERMS)"
else
    echo "   ○ 目录权限可能需要调整 ($DIR_PERMS)"
fi

# 5. 检查.htaccess文件
echo "5. 检查.htaccess文件..."
if [ -f "$WP_PATH/.htaccess" ]; then
    echo "   ✓ .htaccess文件存在"
    
    # 检查基本安全规则
    grep -q "Deny from all" "$WP_PATH/wp-content/uploads/.htaccess" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "   ✓ uploads目录有安全规则"
    else
        echo "   ○ uploads目录可能需要安全规则"
    fi
else
    echo "   ✗ .htaccess文件不存在"
fi

# 6. 检查PHP安全设置
echo "6. 检查PHP安全设置..."
PHP_SETTINGS=("expose_php=Off" "display_errors=Off" "log_errors=On" "allow_url_fopen=Off")

for setting in "${PHP_SETTINGS[@]}"; do
    if php -i | grep -q "$setting"; then
        echo "   ✓ PHP设置: $setting"
    else
        echo "   ○ 建议设置: $setting"
    fi
done

# 7. 检查Apache安全模块
echo "7. 检查Apache安全模块..."
APACHE_MODULES=("mod_security" "mod_evasive")

for module in "${APACHE_MODULES[@]}"; do
    if apache2ctl -M 2>/dev/null | grep -q "$module"; then
        echo "   ✓ Apache模块: $module"
    else
        echo "   ○ 可选模块: $module"
    fi
done

# 8. 检查SSL/TLS
echo "8. 检查SSL/TLS..."
# 这需要实际的HTTPS URL来检查

# 9. 检查备份设置
echo "9. 检查备份..."
if [ -f "/var/backups/wordpress/wp-files-"*".tar.gz" ]; then
    echo "   ✓ 找到备份文件"
else
    echo "   ○ 未找到备份文件"
fi

# 10. 检查自动更新设置
echo "10. 检查自动更新..."
if [ -f "$WP_PATH/wp-config.php" ]; then
    grep -q "WP_AUTO_UPDATE_CORE" "$WP_PATH/wp-config.php"
    if [ $? -eq 0 ]; then
        echo "   ✓ 自动更新设置已配置"
    else
        echo "   ○ 建议配置自动更新"
    fi
fi

echo "安全检查完成!"
echo "建议的安全措施:"
echo "  - 定期更新WordPress核心、主题和插件"
echo "  - 使用强密码和双因素认证"
echo "  - 限制登录尝试次数"
echo "  - 定期备份网站"
echo "  - 使用Web应用防火墙(WAF)"
echo "  - 启用SSL/TLS加密"