#!/bin/bash
# WordPress视频网站管理脚本

case "$1" in
    start)
        echo "启动WordPress视频网站..."
        docker-compose up -d
        echo "WordPress正在启动，请稍等..."
        sleep 30
        echo "访问地址: http://192.168.3.49:8000"
        ;;
    stop)
        echo "停止WordPress视频网站..."
        docker-compose down
        echo "WordPress已停止"
        ;;
    restart)
        echo "重启WordPress视频网站..."
        docker-compose down
        sleep 5
        docker-compose up -d
        echo "WordPress正在重启，请稍等..."
        sleep 30
        echo "访问地址: http://192.168.3.49:8000"
        ;;
    status)
        echo "检查WordPress状态..."
        docker-compose ps
        ;;
    logs)
        echo "查看WordPress日志..."
        docker-compose logs -f wordpress
        ;;
    install-check)
        echo "检查WordPress安装状态..."
        if [ -f "wp-site/wp-config.php" ]; then
            echo "WordPress配置文件存在"
        else
            echo "WordPress配置文件不存在"
        fi
        
        if curl -s http://192.168.3.49:8000 | grep -q "WordPress"; then
            echo "WordPress正在运行"
        else
            echo "WordPress未运行"
        fi
        ;;
    *)
        echo "WordPress视频网站管理脚本"
        echo "使用方法:"
        echo "  ./manage.sh start     - 启动网站"
        echo "  ./manage.sh stop      - 停止网站"
        echo "  ./manage.sh restart   - 重启网站"
        echo "  ./manage.sh status    - 查看状态"
        echo "  ./manage.sh logs      - 查看日志"
        echo "  ./manage.sh install-check - 检查安装状态"
        echo ""
        echo "访问网站: http://192.168.3.49:8000"
        ;;
esac