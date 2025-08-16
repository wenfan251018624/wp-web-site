# WordPress视频网站 - 部署版本

这个目录包含了部署到不同环境所需的精简文件版本。

## 目录结构

```
vps-deployment/
├── wp-site/                    # WordPress网站文件
│   ├── wp-content/            # WordPress内容目录
│   │   └── themes/            # 主题目录
│   │       └── video-theme/   # 自定义视频主题
│   │           ├── style.css  # 主题样式文件
│   │           ├── index.php  # 主模板文件
│   │           └── functions.php # 主题功能文件
│   └── ...                    # 其他WordPress核心文件
├── vps-setup.sh               # VPS服务器初始化脚本
├── deploy-universal.sh        # 跨平台部署脚本（推荐）
├── db-setup.sql               # 数据库配置文件
└── README.md                  # 本文件
```

## 跨平台部署说明（推荐）

### 前提条件

**Linux系统：**
```bash
# 安装必要软件包
sudo apt update && sudo apt install git mysql-server apache2 php libapache2-mod-php php-mysql -y
```

**Mac系统：**
1. 安装Homebrew：
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. 安装必要软件包：
   ```bash
   brew install git mysql php httpd
   ```

### 部署步骤

1. **克隆代码仓库**：
   ```bash
   git clone https://github.com/wenfan251018624/wp-web-site.git
   cd wp-web-site
   ```

2. **运行跨平台部署脚本**：
   ```bash
   # Linux系统（需要root权限）
   sudo bash deploy-universal.sh
   
   # Mac系统（不需要root权限）
   bash deploy-universal.sh
   ```

3. **访问网站**：
   - Linux系统：http://your-server-ip
   - Mac系统：http://localhost/wordpress

### 手动部署步骤

如果您希望手动部署，请参考 [DEPLOYMENT.md](DEPLOYMENT.md) 文件。

## 注意事项

### 跨平台部署
- Linux系统需要root权限运行
- Mac系统不需要root权限
- 脚本会自动检测操作系统并应用相应配置
- 部署完成后请修改默认的数据库密码（生产环境）