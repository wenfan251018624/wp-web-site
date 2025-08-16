# 快速开始指南：本地WordPress视频网站开发

本指南将帮助您快速在本地Mac上设置WordPress视频网站开发环境，并部署您创建的视频主题。

## 前提条件

确保您已经安装了Homebrew。如果没有，请先安装：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 快速安装步骤

### 1. 安装必要的组件

```bash
# 安装Apache、PHP和MySQL
brew install httpd php@8.2 mysql

# 启动服务
brew services start httpd
brew services start mysql
```

### 2. 配置PHP

```bash
# 将PHP添加到系统路径
echo 'export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证安装
php --version
```

### 3. 配置Apache支持PHP

编辑Apache配置文件：
```bash
sudo nano /opt/homebrew/etc/httpd/httpd.conf
```

添加以下行：
```
LoadModule rewrite_module lib/httpd/modules/mod_rewrite.so
LoadModule php_module /opt/homebrew/lib/httpd/modules/libphp.so

<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
```

设置文档根目录：
```
DocumentRoot "/Users/$(whoami)/Sites"
<Directory "/Users/$(whoami)/Sites">
    AllowOverride All
    Require all granted
</Directory>
```

重启Apache：
```bash
brew services restart httpd
```

### 4. 配置MySQL

运行安全安装：
```bash
mysql_secure_installation
```

登录并创建数据库：
```bash
mysql -u root -p
```

执行以下SQL命令：
```sql
CREATE DATABASE wp_video_site;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 5. 部署WordPress网站

```bash
# 创建站点目录
mkdir -p ~/Sites

# 复制您的WordPress网站文件
cp -r /Users/yanwu/Documents/severs/wp-web-site/wp-site ~/Sites/wp-video

# 设置权限
chmod -R 755 ~/Sites/wp-video
```

### 6. 配置WordPress

```bash
# 进入网站目录
cd ~/Sites/wp-video

# 复制配置文件
cp wp-config-sample.php wp-config.php

# 编辑配置文件
nano wp-config.php
```

修改以下配置：
```php
define('DB_NAME', 'wp_video_site');
define('DB_USER', 'wp_user');
define('DB_PASSWORD', 'wp_password');
define('DB_HOST', 'localhost');
```

### 7. 激活自定义主题

访问以下URL完成WordPress安装：
```
http://localhost/wp-video/
```

安装完成后，登录到管理后台：
```
http://localhost/wp-video/wp-login.php
```

在"外观"->"主题"中激活"Video Theme"。

## 测试视频功能

1. 创建新文章，选择"视频"文章格式
2. 在文章内容中添加YouTube视频URL，例如：
   ```
   https://www.youtube.com/watch?v=dQw4w9WgXcQ
   ```
3. 保存并查看文章，视频应该会自动嵌入播放

## 开发工作流程

1. 在`~/Sites/wp-video/wp-content/themes/video-theme/`中编辑主题文件
2. 刷新浏览器查看更改
3. 使用Git管理代码变更：
   ```bash
   cd ~/Sites/wp-video
   git init
   git add .
   git commit -m "Initial commit"
   ```

## 部署到VPS

当本地测试完成后，您可以使用之前创建的脚本部署到VPS：

1. 将代码推送到GitHub
2. 在VPS上运行：
   ```bash
   chmod +x auto-deploy.sh
   sudo ./auto-deploy.sh
   ```

## 故障排除

### 常见问题

1. **页面显示为纯文本（PHP代码未执行）**
   - 确认Apache已正确加载PHP模块
   - 检查httpd.conf中的PHP配置

2. **无法连接数据库**
   - 确认MySQL服务正在运行：`brew services list | grep mysql`
   - 检查wp-config.php中的数据库配置

3. **权限错误**
   - 确保网站目录有正确的权限：`chmod -R 755 ~/Sites/wp-video`

### 查看日志

```bash
# Apache错误日志
tail -f /opt/homebrew/var/log/httpd/error_log

# MySQL错误日志
tail -f /opt/homebrew/var/mysql/$(hostname).err
```

## 下一步

1. 参阅 `LOCAL_DEVELOPMENT_SETUP.md` 获取更详细的配置说明
2. 参阅 `DEPLOYMENT.md` 获取完整的VPS部署指南
3. 在本地环境中充分测试所有功能
4. 使用Git管理您的代码变更