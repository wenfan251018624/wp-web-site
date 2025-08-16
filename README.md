# WordPress视频网站 - 极简部署版本

这个目录包含了部署WordPress视频网站所需的最小化文件。

## 目录结构

```
deploy-version/
├── wp-content/           # WordPress内容目录
│   └── themes/           # 主题目录
│       └── video-theme/  # 自定义视频主题
├── db-setup.sql          # 数据库配置文件
├── deploy-universal.sh   # 跨平台部署脚本
└── README.md             # 本文件
```

## 部署说明

1. **前提条件**：
   - Linux系统：安装必要的软件包
     `sudo apt update && sudo apt install git mysql-server apache2 php libapache2-mod-php php-mysql -y`
   - Mac系统：安装Homebrew和必要软件包
     `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
     `brew install git mysql php httpd`

2. **部署步骤**：
   `sudo bash deploy-universal.sh` (Linux)
   `bash deploy-universal.sh` (Mac)

3. **访问网站**：
   - Linux系统：http://your-server-ip
   - Mac系统：http://localhost/wordpress
