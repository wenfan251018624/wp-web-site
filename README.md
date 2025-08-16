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

1. 克隆项目仓库
2. 安装本地开发环境 (MAMP/Docker/本地LAMP)
3. 配置WordPress
4. 激活自定义视频主题

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
- `test-deploy.sh`: 部署流程测试
- `test-video-embed.sh`: 视频嵌入功能测试
- `test-performance.sh`: 网站性能测试
- `security-check.sh`: 安全设置检查
- `test-restore.sh`: 备份恢复测试

## 维护

1. 定期运行性能测试脚本
2. 执行安全检查
3. 验证备份完整性
4. 更新WordPress核心、主题和插件
5. 监控网站访问日志

## 文档

- `DEPLOYMENT.md`: 详细的部署说明文档
- `README.md`: 项目说明文件

## 许可证

本项目为 proprietary 软件。