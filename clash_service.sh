#!/bin/bash

#=============
# 配置部分
#=============
CLASH_EXEC="./clash-linux-amd64-v1.10.0"
CONFIG_FILE="CreamData_SS_Clash.yaml"
WORK_DIR="."
PID_FILE="$WORK_DIR/clash.pid"

# 写入全局环境变量的文件
ENV_FILE="/etc/profile.d/clash_proxy.sh"

#=============
# 工具函数
#=============

# 检查 Clash 是否在运行
is_running() {
    [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

# 创建写入系统全局的代理环境变量文件
create_env_file() {
    cat <<EOF | sudo tee "$ENV_FILE" >/dev/null
#!/bin/bash
# 该文件由 Clash 控制脚本自动生成/删除
# 当 Clash 运行时，为系统设置代理环境变量
export https_proxy="http://127.0.0.1:7890"
export http_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:8888"
EOF

    sudo chmod +x "$ENV_FILE"
    echo "系统环境变量文件已创建: $ENV_FILE"
}

# 移除全局代理环境变量文件
remove_env_file() {
    if [ -f "$ENV_FILE" ]; then
        sudo rm -f "$ENV_FILE"
        echo "系统环境变量文件已移除: $ENV_FILE"
    fi
}

#=============
# 核心操作
#=============

start() {
    if is_running; then
        echo "Clash 已经在运行 (PID: $(cat "$PID_FILE"))"
    else
        echo "启动 Clash..."
        nohup "$CLASH_EXEC" -f "$CONFIG_FILE" -d "$WORK_DIR" \
            > "$WORK_DIR/clash.log" 2>&1 &
        echo $! > "$PID_FILE"
        echo "Clash 已启动 (PID: $!)"

        # 在系统环境中写入代理变量
        create_env_file
        echo "注意：要在当前终端立刻生效可执行: source $ENV_FILE"
    fi
}

stop() {
    if is_running; then
        echo "停止 Clash (PID: $(cat "$PID_FILE"))..."
        kill "$(cat "$PID_FILE")"
        rm -f "$PID_FILE"
        echo "Clash 已停止"
        
        # 移除系统环境中写的代理变量
        remove_env_file
    else
        echo "Clash 未运行"
    fi
}

status() {
    if is_running; then
        echo "Clash 正在运行 (PID: $(cat "$PID_FILE"))"
    else
        echo "Clash 未运行"
    fi
}

restart() {
    echo "重启 Clash..."
    stop
    start
}

#=============
# 脚本入口
#=============
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    *)
        echo "用法: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
