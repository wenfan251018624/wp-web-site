<?php
/**
 * 自动化WordPress安装脚本
 */

// WordPress安装参数
$params = array(
    'weblog_title' => 'WordPress视频网站',
    'user_name' => 'admin',
    'admin_password' => 'admin123',
    'admin_email' => 'admin@example.com',
    'blog_public' => 1
);

// 创建POST请求数据
$post_data = http_build_query($params);

// WordPress安装URL
$url = 'http://192.168.3.49:8000/wp-admin/install.php?step=2';

// 创建cURL请求
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
    'Content-Type: application/x-www-form-urlencoded',
    'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
));

// 执行请求
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// 检查安装结果
if ($http_code == 200) {
    echo "WordPress安装成功！\n";
    echo "管理员用户名: admin\n";
    echo "管理员密码: admin123\n";
    echo "请访问 http://192.168.3.49:8000 登录后台并创建内容。\n";
} else {
    echo "WordPress安装失败，HTTP状态码: " . $http_code . "\n";
    echo "请手动访问 http://192.168.3.49:8000 完成安装。\n";
}
?>