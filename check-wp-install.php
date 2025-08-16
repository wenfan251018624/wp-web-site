<?php
// 检查WordPress是否已安装
$wp_config_exists = file_exists('wp-site/wp-config.php');
$wordpress_installed = false;

if ($wp_config_exists) {
    // 尝试连接到WordPress数据库检查是否已安装
    require_once('wp-site/wp-config.php');
    
    // 创建连接
    $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
    
    if (!$mysqli->connect_error) {
        // 检查wp_posts表是否存在
        $result = $mysqli->query("SHOW TABLES LIKE 'wp_posts'");
        if ($result && $result->num_rows > 0) {
            $wordpress_installed = true;
        }
        $mysqli->close();
    }
}

if ($wordpress_installed) {
    echo "WordPress已安装\n";
    echo "请访问 http://192.168.3.49:8000 登录后台创建内容\n";
    echo "管理员用户名: admin\n";
    echo "管理员密码: admin123\n";
} else {
    echo "WordPress尚未安装\n";
    echo "请访问 http://192.168.3.49:8000 完成安装\n";
    echo "安装完成后，使用以下信息登录:\n";
    echo "用户名: admin\n";
    echo "密码: admin123\n";
}
?>