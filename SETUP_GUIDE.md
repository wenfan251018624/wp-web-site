# WordPress视频网站设置指南

## 1. 访问网站

打开浏览器访问以下URL：
http://192.168.3.49:8000

## 2. 完成WordPress安装

如果是首次访问，系统会引导你完成WordPress安装：

1. 选择语言（选择"简体中文"）
2. 点击"继续"
3. 填写以下信息：
   - 站点标题：WordPress视频网站
   - 用户名：admin
   - 密码：admin123
   - 邮箱：admin@example.com
4. 点击"安装WordPress"

## 3. 登录后台

安装完成后，访问后台管理界面：
http://192.168.3.49:8000/wp-login.php

使用以下凭据登录：
- 用户名：admin
- 密码：admin123

## 4. 激活YouTube风格主题

1. 登录后台后，点击左侧菜单的"外观" > "主题"
2. 找到"YouTube Style Theme"主题
3. 点击"启用"按钮

## 5. 创建YouTube视频帖子

1. 在WordPress后台，点击"文章" > "写文章"
2. 输入标题（例如：如何使用WordPress创建视频网站）
3. 在内容区域，点击"+"号添加新块
4. 选择"嵌入"块或"YouTube"块
5. 输入YouTube视频URL：
   - https://www.youtube.com/watch?v=gJVdNHSH7hE
   - https://www.youtube.com/watch?v=DK5mmgmkqJE
   - https://www.youtube.com/watch?v=HR0CdYoKtDc
6. 点击"嵌入"或按回车键
7. 可以在视频下方添加描述文字
8. 点击"发布"按钮

## 6. 设置主页

1. 在WordPress后台，点击"设置" > "阅读"
2. 在"首页显示"部分：
   - 选择"一个静态页面"
   - 首页选择"主页"（如果没有，可以先创建一个页面）
3. 点击"保存更改"

## 7. 创建主页页面

1. 在WordPress后台，点击"页面" > "新建页面"
2. 输入页面标题："主页"
3. 在右侧页面属性中，选择模板："YouTube主页模板"
4. 点击"发布"

## 8. 再次设置主页

1. 回到"设置" > "阅读"
2. 在"首页显示"部分，选择刚才创建的"主页"页面
3. 点击"保存更改"

## 9. 添加更多视频内容

重复第5步，添加更多YouTube视频帖子，使用以下URL：
- https://www.youtube.com/watch?v=gJVdNHSH7hE
- https://www.youtube.com/watch?v=DK5mmgmkqJE
- https://www.youtube.com/watch?v=HR0CdYoKtDc

## 故障排除

如果遇到问题：

1. 确保Docker容器正在运行：
   ```bash
   docker-compose ps
   ```

2. 查看容器日志：
   ```bash
   docker-compose logs wordpress
   ```

3. 重启容器：
   ```bash
   docker-compose down && docker-compose up -d
   ```

4. 如果需要重新安装，删除数据库卷：
   ```bash
   docker-compose down -v && docker-compose up -d
   ```