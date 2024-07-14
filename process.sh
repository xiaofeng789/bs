#!/bin/bash

# 备份原始的 proxychains 配置文件
sudo cp /etc/proxychains.conf /etc/proxychains.conf.bak
echo "已备份原始的 ProxyChains 配置文件为 /etc/proxychains.conf.bak"

# 检查是否安装了 proxychains，如果没有则安装它
if ! command -v proxychains &> /dev/null; then
    echo "正在安装 proxychains..."
    sudo apt-get update
    sudo apt-get install -y proxychains
fi

# 安装 curl，如果尚未安装
sudo apt-get update
sudo apt-get install -y curl

# 获取当前机器的 IP 地址
get_ip_address() {
    ip_address=$(sudo ip addr | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
    echo "当前机器的 IP 地址是：$ip_address"
}

# 获取当前的代理服务器配置
get_current_proxy() {
    current_proxy=$(sudo awk '/^\[ProxyList\]/{f=1} f' /etc/proxychains.conf)
    echo "从 [ProxyList] 开始的代理配置如下：$current_proxy"
}

# 删除响应文件
delete_response_files() {
    for i in {1..3}; do
        rm -f "google_response_$i.txt"
        rm -f "google_response_after_proxy_$i.txt"
    done
    echo "已删除所有响应文件."
}

# 通过 proxychains curl 测试访问 Google
for i in {1..3}; do
    echo "正在尝试通过代理访问 Google 第 $i 次..."
    proxychains curl -o "google_response_$i.txt" www.google.com
    cat "google_response_$i.txt"  # 打印文件内容
done

# 打印当前代理服务器配置
get_current_proxy
# 打印当前机器的 IP 地址
get_ip_address

# 获取用户输入的代理服务器 IP 地址
read -p "请输入新的代理服务器的 IP 地址（留空则不修改）: " proxy_ip

# 获取用户输入的代理服务器端口号
read -p "请输入新的代理服务器的端口号（留空则不修改）: " proxy_port

# 初始化标志变量以检查代理设置是否更新
proxy_changed=false

# 读取当前的socks5代理配置
proxy_line=$(awk '/^\[ProxyList\]/{flag=1;next}/^$/{flag=0}flag' /etc/proxychains.conf | grep 'socks5')

# 提取当前的IP地址和端口
current_ip=$(echo $proxy_line | awk '{print $2}')
current_port=$(echo $proxy_line | awk '{print $3}')

# 根据用户输入修改 proxychains 配置文件
if [[ -n $proxy_ip || -n $proxy_port ]]; then
    echo "正在修改 ProxyChains 配置文件..."

    # 仅在用户输入新值时进行修改
    if [[ -n $proxy_ip ]]; then
        sudo sed -i "/^\[ProxyList\]/,/^$/ s/\(socks5 \)[^ ]*\( .*\)/\1$proxy_ip\2/" /etc/proxychains.conf
        echo "ProxyChains 的 IP 地址已成功修改为：$proxy_ip"
        proxy_changed=true
    fi

    if [[ -n $proxy_port ]]; then
        sudo sed -i "/^\[ProxyList\]/,/^$/ s/\(socks5 [^ ]* \)[^ ]*/\1$proxy_port/" /etc/proxychains.conf
        echo "ProxyChains 的端口号已成功修改为：$proxy_port"
        proxy_changed=true
    fi
fi

# 如果代理配置发生变化，则通过 proxychains curl 再次测试访问 Google
if $proxy_changed; then
    for i in {1..3}; do
        echo "正在尝试通过代理访问 Google 第 $i 次..."
        proxychains curl -o "google_response_after_proxy_$i.txt" www.google.com
        cat "google_response_after_proxy_$i.txt"  # 打印文件内容
    done
fi

# 删除响应文件
delete_response_files

