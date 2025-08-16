# 使用Docker进行WordPress本地开发

本指南介绍如何使用Docker快速搭建WordPress本地开发环境，无需复杂的本地配置。

## 前提条件

1. 安装Docker Desktop for Mac
   - 下载地址: https://www.docker.com/products/docker-desktop/
   - 安装后启动Docker Desktop

## 快速开始

### 1. 启动开发环境

在项目根目录运行:

```bash
./start-with-docker.sh
```

脚本会自动:
- 检查Docker是否已安装
- 启动WordPress和MySQL容器
- 挂载本地代码目录

### 2. 访问WordPress

启动成功后，通过以下URL访问:

- WordPress网站: http://localhost:8080
- WordPress管理后台: http://localhost:8080/wp-admin

### 3. 数据库信息

Docker环境会自动创建MySQL数据库:

- 数据库主机: db (Docker内部网络)
- 数据库端口: 3306
- 数据库名: wp_video_site
- 用户名: wp_user
- 密码: wp_password
- root密码: rootpassword

## 开发工作流程

### 修改代码

您的代码文件位于本地的 `wp-site` 目录中，所有更改会实时同步到容器内。

### 数据持久化

数据库数据会保存在Docker卷中，即使容器停止也不会丢失。

### 管理命令

```bash
# 停止并清理环境
./start-with-docker.sh down

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs

# 重启环境
docker-compose restart
```

## 文件结构

```
wp-web-site/
├── docker-compose.yml      # Docker配置文件
├── start-with-docker.sh    # 启动脚本
├── wp-site/               # WordPress文件目录
│   ├── wp-content/        # WordPress内容目录
│   │   └── themes/        # 主题目录
│   │       └── video-theme/ # 您的视频主题
│   └── ...                # 其他WordPress文件
```

## 优势

1. **环境一致性** - 开发、测试、生产环境完全一致
2. **快速启动** - 一条命令即可启动完整环境
3. **隔离性好** - 不会影响本地系统配置
4. **易于分享** - 团队成员可以快速复制相同环境

## 故障排除

### 常见问题

1. **端口冲突**
   - 错误信息: "port is already allocated"
   - 解决方法: 修改docker-compose.yml中的端口映射

2. **权限问题**
   - 错误信息: "permission denied"
   - 解决方法: 检查文件权限，确保Docker有访问权限

3. **容器启动失败**
   - 解决方法: 查看日志 `docker-compose logs`

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs wordpress
docker-compose logs db
```

## 部署到生产环境

本地开发完成后，使用以下脚本部署到VPS:

```bash
# 确保代码已提交到Git
git add .
git commit -m "Your changes"
git push origin main

# 在VPS上运行部署脚本
./auto-deploy.sh
```

## 最佳实践

1. **版本控制** - 使用Git管理所有代码更改
2. **定期备份** - 虽然数据持久化，但仍建议定期备份
3. **环境隔离** - 为不同项目使用不同的Docker环境
4. **资源管理** - 不使用时及时停止容器以节省资源

## 进一步学习

- Docker官方文档: https://docs.docker.com/
- Docker Compose文档: https://docs.docker.com/compose/
- WordPress开发手册: https://developer.wordpress.org/