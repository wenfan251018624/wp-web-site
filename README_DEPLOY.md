# WordPress视频网站一键部署

## 简介

这个项目包含优化的一键部署脚本，可以直接在git clone后的环境中运行，无需额外配置。

### Ubuntu/Debian系统
使用 `deploy.sh` 脚本

### CentOS 7系统
使用 `deploy-centos.sh` 脚本

## 使用方法

### 1. 克隆仓库

```bash
git clone https://github.com/wenfan251018624/wp-web-site.git
cd wp-web-site
```

### 2. 运行部署脚本

```bash
# 显示帮助信息
bash deploy.sh

# 执行完整安装部署
bash deploy.sh --install

# 更新现有部署
bash deploy.sh --update
```

### 3. 访问网站

部署完成后，可以通过服务器IP地址访问网站：
- http://your-server-ip

## 脚本特性

1. **自动检测系统环境**：自动检测操作系统类型和版本
2. **智能包管理**：自动检查并安装缺失的软件包
3. **权限自适应**：支持root和非root用户运行（需要sudo权限）
4. **错误处理**：完善的错误处理和日志输出
5. **一键操作**：支持安装和更新两种模式
6. **安全配置**：自动配置WordPress安全密钥

## 系统要求

- Ubuntu 20.04 LTS 或更高版本
- 至少2GB内存
- 至少20GB磁盘空间
- Root或sudo权限

## 部署后配置

### 1. 修改默认密码

建议在生产环境中修改默认的数据库密码：
- 数据库名: `wp_video_site`
- 用户名: `wp_user`
- 密码: `wp_password`

### 2. 配置域名

编辑Apache配置文件以使用自定义域名：
```bash
sudo nano /etc/apache2/sites-available/wordpress.conf
```

### 3. 配置SSL证书

使用Let's Encrypt免费SSL证书：
```bash
sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d your-domain.com
```

## 故障排除

### 查看部署日志

```bash
# 查看Apache错误日志
sudo tail -f /var/log/apache2/error.log

# 查看MySQL错误日志
sudo tail -f /var/log/mysql/error.log
```

### 重新部署

如果需要重新部署，可以先清理环境：
```bash
# 停止服务
sudo systemctl stop apache2
sudo systemctl stop mysql

# 删除数据库
sudo mysql -e "DROP DATABASE wp_video_site;"
sudo mysql -e "DROP USER 'wp_user'@'localhost';"

# 重新运行部署脚本
bash deploy.sh --install
```

## 支持

如有问题，请提交issue或联系项目维护者。