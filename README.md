# WordPress视频网站项目

这是一个类YouTube的WordPress视频网站项目，支持嵌入第三方视频链接，使用Git进行版本控制和部署管理。

## 项目结构

```
wp-web-site/
├── wp-site/                    # WordPress网站根目录
│   ├── wp-content/            # WordPress内容目录
│   │   └── themes/            # 主题目录
│   │       └── video-theme/   # 自定义视频主题
│   │           ├── style.css  # 主题样式文件
│   │           ├── index.php  # 主模板文件
│   │           └── functions.php # 主题功能文件
│   ├── wp-config.php          # WordPress配置文件
│   └── ...                    # 其他WordPress核心文件
├── .git/                      # Git版本控制目录
├── .gitignore                 # Git忽略文件配置
├── DEPLOYMENT.md              # 部署说明文档
├── README.md                  # 项目说明文件
├── QUICK_START.md             # 快速开始指南
├── LOCAL_DEVELOPMENT_SETUP.md # 本地开发环境详细设置
├── DOCKER_DEVELOPMENT.md      # Docker开发环境说明
├── docker-compose.yml         # Docker配置文件
├── start-with-docker.sh       # Docker启动脚本
├── test-local.sh              # 本地测试脚本
├── vps-setup.sh              # VPS环境安装脚本
├── db-setup.sql              # 数据库配置脚本
├── apache-config.conf        # Apache配置文件
├── permissions-setup.sh      # 文件权限设置脚本
├── clone-repo.sh             # 克隆GitHub仓库脚本
├── wp-config-setup.sh        # WordPress配置脚本
├── deploy.sh                 # 部署脚本
├── auto-deploy.sh            # 自动部署脚本
├── ssl-setup.sh              # SSL证书配置脚本
├── backup.sh                 # 定期备份脚本
├── test-deploy.sh            # 部署测试脚本
├── test-video-embed.sh       # 视频嵌入测试脚本
├── test-performance.sh       # 性能测试脚本
├── security-check.sh         # 安全检查脚本
└── test-restore.sh           # 备份恢复测试脚本
```

## 功能特点

1. **视频嵌入支持**: 主题支持嵌入YouTube、Vimeo等第三方视频平台的视频
2. **响应式设计**: 适配各种设备屏幕尺寸
3. **版本控制**: 使用Git进行代码版本管理
4. **自动化部署**: 提供一键部署脚本
5. **安全性**: 包含安全配置和检查脚本
6. **备份恢复**: 提供定期备份和恢复测试功能

## 快速开始

### 本地开发

有多种方式进行本地开发：

#### 方式1: 使用Docker (推荐)
这是最简单的方式，无需配置复杂的本地环境：

1. 安装Docker Desktop for Mac: https://www.docker.com/products/docker-desktop/
2. 运行启动脚本:
   ```bash
   ./start-with-docker.sh
   ```
3. 访问 http://localhost:8080 开始使用

#### 方式2: 手动配置本地环境
如果不想使用Docker，请参考以下文档：
- `QUICK_START.md`: 快速设置指南
- `LOCAL_DEVELOPMENT_SETUP.md`: 详细设置说明

#### 方式3: 简单的PHP服务器测试
对于快速预览，可以使用PHP内置服务器：
```bash
./test-local.sh
```

### 远程部署

1. 准备VPS服务器
2. 运行 `vps-setup.sh` 安装LAMP环境
3. 配置数据库 `db-setup.sql`
4. 配置Web服务器 `apache-config.conf`
5. 设置文件权限 `permissions-setup.sh`
6. 克隆代码 `clone-repo.sh`
7. 配置WordPress `wp-config-setup.sh`
8. 启用SSL证书 `ssl-setup.sh`
9. 设置自动部署 `auto-deploy.sh`

## 部署脚本说明

### 本地开发脚本
- `start-with-docker.sh`: 使用Docker启动开发环境
- `test-local.sh`: 使用PHP内置服务器快速测试
- `docker-compose.yml`: Docker环境配置

### 远程部署脚本
- `vps-setup.sh`: 在VPS上安装LAMP环境
- `db-setup.sql`: 配置MySQL数据库
- `apache-config.conf`: Apache虚拟主机配置
- `permissions-setup.sh`: 设置文件权限
- `clone-repo.sh`: 从GitHub克隆代码
- `wp-config-setup.sh`: 配置WordPress数据库连接
- `deploy.sh`: 基本部署脚本
- `auto-deploy.sh`: 自动化部署脚本
- `ssl-setup.sh`: 配置SSL证书
- `backup.sh`: 定期备份脚本

### 测试和维护脚本
- `test-deploy.sh`: 部署流程测试
- `test-video-embed.sh`: 视频嵌入功能测试
- `test-performance.sh`: 网站性能测试
- `security-check.sh`: 安全设置检查
- `test-restore.sh`: 备份恢复测试

## 文档

- `DEPLOYMENT.md`: 详细的部署说明文档
- `README.md`: 项目说明文件
- `QUICK_START.md`: 快速开始指南
- `LOCAL_DEVELOPMENT_SETUP.md`: 本地开发环境详细设置
- `DOCKER_DEVELOPMENT.md`: Docker开发环境说明

## 许可证

本项目为 proprietary 软件。