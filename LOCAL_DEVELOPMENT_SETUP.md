# 本地WordPress开发环境设置指南

本指南将帮助您在macOS系统上设置完整的WordPress本地开发环境，包括Apache、PHP、MySQL的安装和配置。

## 目录

1. [系统要求](#系统要求)
2. [安装Homebrew](#安装homebrew)
3. [安装Apache](#安装apache)
4. [安装PHP](#安装php)
5. [安装MySQL](#安装mysql)
6. [配置Apache以支持PHP](#配置apache以支持php)
7. [配置MySQL](#配置mysql)
8. [下载并安装WordPress](#下载并安装wordpress)
9. [创建WordPress数据库](#创建wordpress数据库)
10. [配置WordPress](#配置wordpress)
11. [启动和测试环境](#启动和测试环境)
12. [故障排除](#故障排除)
13. [常用管理命令](#常用管理命令)
14. [开发最佳实践](#开发最佳实践)
15. [替代方案](#替代方案)

## 系统要求

- macOS 10.14或更高版本
- 至少4GB RAM
- 至少10GB可用磁盘空间
- 管理员权限

## 安装Homebrew

Homebrew是macOS的包管理器，可以简化软件安装过程。

1. 打开终端应用
2. 运行以下命令安装Homebrew：
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. 安装完成后，验证Homebrew：
   ```bash
   brew --version
   ```

## 安装Apache

macOS自带Apache，但我们可以使用Homebrew安装最新版本以获得更好的兼容性。

1. 安装Apache：
   ```bash
   brew install httpd
   ```
2. 启动Apache服务：
   ```bash
   brew services start httpd
   ```
3. 验证安装：
   ```bash
   brew services list | grep httpd
   ```

## 安装PHP

1. 搜索可用的PHP版本：
   ```bash
   brew search php
   ```
2. 安装PHP（推荐使用较新版本，如PHP 8.2）：
   ```bash
   brew install php@8.2
   ```
3. 将PHP添加到系统路径：
   ```bash
   echo 'export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
4. 验证PHP安装：
   ```bash
   php --version
   ```

## 安装MySQL

1. 安装MySQL：
   ```bash
   brew install mysql
   ```
2. 启动MySQL服务：
   ```bash
   brew services start mysql
   ```
3. 验证MySQL安装：
   ```bash
   mysql --version
   ```

## 配置Apache以支持PHP

1. 找到Apache配置文件：
   ```bash
   sudo nano /opt/homebrew/etc/httpd/httpd.conf
   ```
2. 在配置文件中添加以下行以加载PHP模块（找到类似行并取消注释）：
   ```
   LoadModule rewrite_module lib/httpd/modules/mod_rewrite.so
   LoadModule php_module /opt/homebrew/lib/httpd/modules/libphp.so
   ```
3. 添加PHP文件类型处理：
   ```
   <FilesMatch \.php$>
       SetHandler application/x-httpd-php
   </FilesMatch>
   ```
4. 设置文档根目录（找到DocumentRoot并修改）：
   ```
   DocumentRoot "/Users/你的用户名/Sites"
   <Directory "/Users/你的用户名/Sites">
       AllowOverride All
       Require all granted
   </Directory>
   ```
5. 重启Apache服务：
   ```bash
   brew services restart httpd
   ```

## 配置MySQL

1. 运行MySQL安全安装脚本：
   ```bash
   mysql_secure_installation
   ```
2. 按照提示设置root密码并配置安全选项
3. 登录MySQL：
   ```bash
   mysql -u root -p
   ```
4. 创建WordPress数据库用户：
   ```sql
   CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
   CREATE DATABASE wp_video_site;
   GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

## 下载并安装WordPress

1. 创建站点目录：
   ```bash
   mkdir -p ~/Sites
   ```
2. 下载WordPress：
   ```bash
   cd ~/Sites
   curl -O https://wordpress.org/latest.tar.gz
   ```
3. 解压WordPress：
   ```bash
   tar -xzf latest.tar.gz
   mv wordpress wp-video
   ```
4. 设置文件权限：
   ```bash
   chmod -R 755 wp-video
   ```

## 创建WordPress数据库

1. 登录MySQL：
   ```bash
   mysql -u root -p
   ```
2. 创建数据库和用户：
   ```sql
   CREATE DATABASE wp_video_site;
   CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
   GRANT ALL PRIVILEGES ON wp_video_site.* TO 'wp_user'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

## 配置WordPress

1. 进入WordPress目录：
   ```bash
   cd ~/Sites/wp-video
   ```
2. 复制配置文件：
   ```bash
   cp wp-config-sample.php wp-config.php
   ```
3. 编辑配置文件：
   ```bash
   nano wp-config.php
   ```
4. 修改数据库配置：
   ```php
   define('DB_NAME', 'wp_video_site');
   define('DB_USER', 'wp_user');
   define('DB_PASSWORD', 'wp_password');
   define('DB_HOST', 'localhost');
   ```

## 启动和测试环境

1. 确保所有服务都在运行：
   ```bash
   brew services list | grep -E "(httpd|mysql)"
   ```
2. 在浏览器中访问：
   ```
   http://localhost:8080/wp-video/
   ```
3. 按照WordPress安装向导完成安装

## 故障排除

### 常见问题

1. **Apache无法启动**
   - 检查端口是否被占用：`lsof -i :8080`
   - 检查配置文件语法：`httpd -t`

2. **PHP未被解析**
   - 确认Apache配置文件中已加载PHP模块
   - 检查文件权限

3. **MySQL连接失败**
   - 确认MySQL服务正在运行
   - 检查用户名和密码
   - 验证数据库是否存在

4. ** WordPress无法连接数据库**
   - 检查wp-config.php中的配置
   - 确认MySQL用户权限

### 日志文件位置

- Apache错误日志：`/opt/homebrew/var/log/httpd/error_log`
- MySQL错误日志：`/opt/homebrew/var/mysql/你的计算机名.err`

## 常用管理命令

### Apache管理
```bash
# 启动Apache
brew services start httpd

# 停止Apache
brew services stop httpd

# 重启Apache
brew services restart httpd

# 重新加载配置
sudo brew services reload httpd
```

### MySQL管理
```bash
# 启动MySQL
brew services start mysql

# 停止MySQL
brew services stop mysql

# 重启MySQL
brew services restart mysql

# 登录MySQL
mysql -u root -p
```

### PHP管理
```bash
# 检查PHP版本
php --version

# 检查PHP配置
php -i

# 检查已安装的PHP模块
php -m
```

## 开发最佳实践

1. **版本控制**
   - 使用Git管理代码变更
   - 创建不同的分支进行功能开发

2. **数据库管理**
   - 定期备份数据库
   - 在不同环境使用不同的数据库

3. **环境配置**
   - 使用不同的wp-config.php配置文件用于不同环境
   - 使用环境变量管理敏感信息

4. **主题和插件开发**
   - 在本地环境中充分测试后再部署
   - 使用子主题进行定制开发

## 替代方案

如果您觉得手动配置过程复杂，可以考虑以下集成解决方案：

### 1. MAMP
- 下载：https://www.mamp.info/en/downloads/
- 特点：图形界面，易于安装和管理

### 2. Local by Flywheel
- 下载：https://localwp.com/
- 特点：专门为WordPress设计，一键创建站点

### 3. DevKinsta
- 下载：https://kinsta.com/devkinsta/
- 特点：免费，现代化界面，支持Docker

### 4. Docker (高级用户)
- 使用Docker Compose配置LAMP环境
- 便于环境复制和部署

这些工具可以大大简化本地开发环境的设置过程，特别适合不熟悉服务器配置的用户。

## 结语

通过以上步骤，您应该能够成功在本地搭建WordPress开发环境。这个环境可以用于开发、测试和调试您的视频网站，而不会影响生产环境。

记住定期备份数据库和代码，并在每次重大更改前创建恢复点，以确保开发过程的安全性。