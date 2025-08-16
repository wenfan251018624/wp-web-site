# WordPress视频网站部署说明

本文档详细说明了如何部署一个类YouTube的WordPress视频网站，包括本地开发环境搭建和远程服务器部署。

## 目录

1. [本地开发环境搭建](#本地开发环境搭建)
2. [远程服务器配置](#远程服务器配置)
3. [部署流程](#部署流程)
4. [维护和监控](#维护和监控)

## 本地开发环境搭建

### 1. 环境要求

- macOS 或 Linux 操作系统
- PHP 7.4 或更高版本
- MySQL 5.7 或更高版本
- Apache 或 Nginx Web服务器
- Git 版本控制工具

### 2. 安装步骤

1. **安装开发工具**
   ```bash
   # 安装Homebrew (macOS)
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # 安装PHP和MySQL
   brew install php mysql
   ```

2. **安装WordPress**
   ```bash
   # 下载WordPress
   curl -O https://wordpress.org/latest.tar.gz
   tar -xzf latest.tar.gz
   
   # 配置WordPress
   cp wordpress/wp-config-sample.php wordpress/wp-config.php
   ```

3. **创建自定义主题**
   - 主题目录: `wp-content/themes/video-theme/`
   - 包含文件:
     - `style.css`: 主题样式文件
     - `index.php`: 主模板文件
     - `functions.php`: 主题功能文件

4. **配置视频嵌入功能**
   - 在`functions.php`中添加视频支持:
     ```php
     add_theme_support('post-formats', array('video'));
     add_theme_support('post-thumbnails');
     ```
   - 允许iframe标签用于视频嵌入

### 5. 版本控制

1. **初始化Git仓库**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **配置.gitignore**
   ```
   wp-config.php
   wp-content/uploads/
   .DS_Store
   ```

3. **创建开发分支**
   ```bash
   git checkout -b development
   ```

## 远程服务器配置

### 1. 服务器要求

- Ubuntu 18.04 LTS 或更高版本
- 至少 2GB RAM
- 至少 20GB 磁盘空间
- 公网IP地址和域名

### 2. 安装LAMP环境

使用提供的脚本 `vps-setup.sh`:

```bash
chmod +x vps-setup.sh
sudo ./vps-setup.sh
```

该脚本将自动安装:
- Apache Web服务器
- MySQL数据库
- PHP及相关模块
- Git版本控制工具

### 3. 配置MySQL数据库

使用提供的脚本 `db-setup.sql`:

```bash
mysql -u root -p < db-setup.sql
```

数据库配置:
- 数据库名: `wp_video_site`
- 用户名: `wp_user`
- 密码: `wp_password`

### 4. 配置Web服务器

1. **Apache配置**
   使用提供的配置文件 `apache-config.conf`:
   ```bash
   sudo cp apache-config.conf /etc/apache2/sites-available/000-default.conf
   sudo systemctl reload apache2
   ```

2. **启用必要模块**
   ```bash
   sudo a2enmod rewrite
   sudo a2enmod headers
   sudo systemctl reload apache2
   ```

### 5. 设置文件权限

使用提供的脚本 `permissions-setup.sh`:

```bash
chmod +x permissions-setup.sh
sudo ./permissions-setup.sh
```

## 部署流程

### 1. 克隆GitHub仓库

使用提供的脚本 `clone-repo.sh`:

```bash
chmod +x clone-repo.sh
sudo ./clone-repo.sh
```

### 2. 配置WordPress

使用提供的脚本 `wp-config-setup.sh`:

```bash
chmod +x wp-config-setup.sh
sudo ./wp-config-setup.sh
```

### 3. 自动部署

使用提供的脚本 `auto-deploy.sh`:

```bash
chmod +x auto-deploy.sh
sudo ./auto-deploy.sh
```

该脚本将:
- 更新系统包
- 检查并安装必要软件
- 克隆/更新代码
- 配置文件权限
- 重启Web服务器

### 4. SSL证书配置

使用提供的脚本 `ssl-setup.sh`:

```bash
chmod +x ssl-setup.sh
sudo ./ssl-setup.sh
```

该脚本使用Let's Encrypt免费SSL证书。

### 5. 定期备份

使用提供的脚本 `backup.sh`:

```bash
chmod +x backup.sh
sudo ./backup.sh
```

## 维护和监控

### 1. 性能测试

使用提供的脚本 `test-performance.sh`:

```bash
chmod +x test-performance.sh
./test-performance.sh
```

### 2. 安全检查

使用提供的脚本 `security-check.sh`:

```bash
chmod +x security-check.sh
./security-check.sh
```

### 3. 备份恢复测试

使用提供的脚本 `test-restore.sh`:

```bash
chmod +x test-restore.sh
./test-restore.sh
```

### 4. 部署流程测试

使用提供的脚本 `test-deploy.sh`:

```bash
chmod +x test-deploy.sh
./test-deploy.sh
```

## 故障排除

### 常见问题

1. **网站无法访问**
   - 检查Apache服务状态: `sudo systemctl status apache2`
   - 检查防火墙设置: `sudo ufw status`

2. **数据库连接失败**
   - 检查MySQL服务状态: `sudo systemctl status mysql`
   - 验证数据库配置: `mysql -u wp_user -pwp_password wp_video_site`

3. **视频无法播放**
   - 检查主题是否支持视频嵌入
   - 验证iframe权限设置

### 日志文件

- Apache错误日志: `/var/log/apache2/error.log`
- Apache访问日志: `/var/log/apache2/access.log`
- MySQL错误日志: `/var/log/mysql/error.log`
- 系统日志: `/var/log/syslog`

## 附录

### 脚本列表

1. `vps-setup.sh` - VPS环境安装
2. `db-setup.sql` - 数据库配置
3. `apache-config.conf` - Apache配置
4. `permissions-setup.sh` - 文件权限设置
5. `clone-repo.sh` - 克隆GitHub仓库
6. `wp-config-setup.sh` - WordPress配置
7. `auto-deploy.sh` - 自动部署
8. `ssl-setup.sh` - SSL证书配置
9. `backup.sh` - 定期备份
10. `test-deploy.sh` - 部署测试
11. `test-video-embed.sh` - 视频嵌入测试
12. `test-performance.sh` - 性能测试
13. `security-check.sh` - 安全检查
14. `test-restore.sh` - 备份恢复测试

### 主题文件

- `wp-content/themes/video-theme/style.css` - 主题样式
- `wp-content/themes/video-theme/index.php` - 主模板
- `wp-content/themes/video-theme/functions.php` - 主题功能