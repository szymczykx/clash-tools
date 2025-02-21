# Terminals Setup 指南

本文整理了使用 Clash 启动代理的基本流程及常用代理配置方法。

## 第一部分：运行 Clash 启动代理

1. 开启一个新的 Terminal 运行以下命令

   ```bash
   # 下载 Clash
   curl https://glados.rocks/tools/clash-linux.zip -o clash.zip
   
   # 解压并进入目录
   unzip clash.zip
   cd clash
   
   # 下载终端配置文件
   curl https://xxxx/xxxx.yaml > xxxx.yaml
   
   # 设置执行权限
   chmod +x ./clash-linux-amd64-v1.10.0
   
   # 启动 Clash
   ./clash-linux-amd64-v1.10.0 -f xxxx.yaml -d .
   ```

   启动成功时会看到类似以下日志：
   
   ```bash
   INFO[0000] HTTP proxy listening at: [::]:7890
   INFO[0000] SOCKS proxy listening at: [::]:7891
   INFO[0000] RESTful API listening at: 127.0.0.1:9090
   ```

## 第二部分：配置代理

### Git 示例

在另一个 Terminal 中执行：

```bash
git clone https://github.com/twbs/bootstrap.git --config "http.proxy=127.0.0.1:7890"
```

### NPM 示例

```bash
# 设置代理
npm config set proxy http://127.0.0.1:7890

# 安装全局包
npm install pm2 -g

# 取消代理设置
npm config delete proxy
```

### Shell 环境变量（适用于 APT/CURL 等）

```bash
# 设置代理
export http_proxy="127.0.0.1:7890"

# 更新或安装软件
apt update
apt install wget

# 测试代理
curl https://ifconfig.me

# 取消代理设置
export http_proxy=""
```

### SSH 代理配置

在 `~/.ssh/config` 中添加：

```text
Host 1.1.1.1
  User root
  ProxyCommand /usr/bin/nc -X5 -x 127.0.0.1:7891  %h %p
```

然后通过 SSH 连接：

```bash
ssh root@1.1.1.1
```

### 桌面型 Linux 代理设置

例如在 Ubuntu 22.04 中，在系统设置内将网络代理模式设置为 SOCKS5，地址为 127.0.0.1，端口为 7891。

**注意**：ping 命令并非 TCP 应用，因此无法使用 Clash 的 HTTP/SOCKS5 代理。

## 第三部分：管理 Clash（可选）

- 使用 [Web UI 管理 Clash](http://127.0.0.1:9090/ui)，填写端口9090。
