#!/bin/bash

# Function to check current Node.js version
check_node_version() {
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
        if [ "$NODE_VERSION" -ge 22 ]; then
            return 0 # Version is OK
        else
            return 1 # Version is old
        fi
    else
        return 2 # Not installed
    fi
}

# Function to install Node.js 22
install_node() {
    OS=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi

    echo "检测到的操作系统: $OS"

    case "$OS" in
        ubuntu|debian)
            echo "正在为 Debian/Ubuntu 安装 Node.js 22..."
            # Update and install prerequisites
            sudo apt-get update
            sudo apt-get install -y curl
            # Download and run the NodeSource setup script
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            # Install Node.js
            sudo apt-get install -y nodejs
            ;;
        centos|rhel|fedora|almalinux|rocky)
            if [[ ("$OS" == "centos" || "$OS" == "rhel") && "$VERSION_ID" == "7"* ]]; then
                echo "错误：CentOS/RHEL 7 系统 GLIBC 版本过低(2.17)，无法运行 Node.js 22 (需要 GLIBC 2.28+)。"
                echo "openclaw 需要 Node.js 22+ 环境。"
                echo "建议方案："
                echo "1. 升级操作系统至 CentOS 8/9 或使用 Ubuntu 22+。"
                echo "2. 使用 Docker 容器运行 openclaw。"
                exit 1
            fi
            echo "正在为 RHEL/CentOS/Fedora 安装 Node.js 22..."
            # Install prerequisites
            sudo yum install -y curl
            # Download and run the NodeSource setup script
            curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
            # Install Node.js
            sudo yum install -y nodejs
            ;;
        *)
            echo "不支持或未知的操作系统，无法自动安装: $OS"
            echo "请手动安装 Node.js 22。"
            exit 1
            ;;
    esac
}

# Main logic
check_node_version
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Node.js 22+ 已安装。"
else
    if [ $STATUS -eq 2 ]; then
        echo "Node.js 未安装。"
    else
        echo "当前 Node.js 版本低于 22。"
    fi

    echo "需要 Node.js 22 或更高版本。"
    read -p "您是否要安装/升级到 Node.js 22？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_node
        # Verify installation
        check_node_version
        if [ $? -ne 0 ]; then
             echo "Node.js 安装失败或版本仍然不正确。"
             exit 1
        fi
        echo "Node.js 安装成功完成。"
        echo "当前 Node.js 版本: $(node -v)"
        echo "下一步: 正在安装 openclaw..."
    else
        echo "已中止。需要 Node.js 22+。"
        exit 1
    fi
fi

# Install openclaw function
install_openclaw_pkg() {
    read -p "是否确认安装 openclaw？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在运行 openclaw 安装..."
        sudo npm install -g openclaw@latest --registry https://registry.npmmirror.com
    else
        echo "取消安装。"
        return 1
    fi
}

# Install feishu plugin function
install_feishu() {
    echo "正在安装飞书插件 @m1heng-clawd/feishu ..."
    sudo openclaw plugins install @m1heng-clawd/feishu
}

# 1. OpenClaw Installation Logic
if command -v openclaw >/dev/null 2>&1; then
    echo "检测到 openclaw 已安装。"
    read -p "是否卸载当前版本并重新安装？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在卸载旧版本 openclaw..."
        sudo npm uninstall -g openclaw
        install_openclaw_pkg
        if [ $? -ne 0 ]; then
             echo "openclaw 重装失败。"
             exit 1
        fi
        echo "openclaw 重装完成。"
    else
        echo "跳过 openclaw 安装，使用现有版本。"
    fi
else
    install_openclaw_pkg
    if [ $? -ne 0 ]; then
         echo "openclaw 安装失败。"
         exit 1
    fi
    echo "openclaw 安装完成。"
fi

# 2. Feishu Plugin Installation Logic
if command -v openclaw >/dev/null 2>&1; then
    echo "下一步: 检查飞书插件..."
    
    # Check if plugin exists (naive check using list)
    # Try both sudo and non-sudo list, and check common directories
    PLUGIN_FOUND=false
    
    # 1. Check using CLI (suppress warnings/errors to just check output)
    if openclaw plugins ls 2>/dev/null | grep -q "feishu"; then
        PLUGIN_FOUND=true
    elif sudo openclaw plugins ls 2>/dev/null | grep -q "feishu"; then
        PLUGIN_FOUND=true
    fi

    # 2. Check directories directly
    if [ "$PLUGIN_FOUND" = false ]; then
        # Check current user's directory
        if [ -d "$HOME/.openclaw/extensions/feishu" ]; then
            PLUGIN_FOUND=true
        # Check root's directory (requires sudo if not root)
        elif sudo test -d "/root/.openclaw/extensions/feishu"; then
            PLUGIN_FOUND=true
        # Check global installation directory (based on user logs)
        elif sudo test -d "/usr/lib/node_modules/openclaw/extensions/feishu"; then
             PLUGIN_FOUND=true
        fi
    fi

    if [ "$PLUGIN_FOUND" = true ]; then
        echo "检测到飞书插件 @m1heng-clawd/feishu 已安装。"
        read -p "是否卸载当前插件并重新安装？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "正在卸载旧版本插件..."
            sudo openclaw plugins uninstall @m1heng-clawd/feishu
            install_feishu
        else
             echo "跳过飞书插件安装。"
        fi
    else
        install_feishu
    fi
    
    if [ $? -eq 0 ]; then
        echo "飞书插件检查/安装完成。"
        
        echo "openclaw 及其插件已准备就绪。"
        echo "您可以运行配置向导来进行一系列初始化配置。"
        read -p "是否立即运行 openclaw onboard 向导？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "正在启动配置向导..."
            sudo openclaw onboard
        else
            echo "您可以稍后通过运行 'sudo openclaw onboard' 来启动配置向导。"
        fi
    else
        echo "飞书插件安装失败。"
        exit 1
    fi
else
    echo "错误：找不到 openclaw 命令，无法安装插件。"
    exit 1
fi

