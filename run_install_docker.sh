#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 输出带颜色的信息函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查是否在 /root 目录下
if [[ "$SCRIPT_DIR" == "/root"* ]]; then
    warning "检测到脚本位于 /root 目录下 ($SCRIPT_DIR)"
    warning "为避免潜在的权限问题，建议在 /dev-ops 目录下运行"
    echo "-----------------------------------------------------------"
    info "建议操作步骤："
    echo "1. 创建并进入工作目录："
    echo "   cd / && mkdir -p dev-ops && cd dev-ops"
    echo "2. 在此目录下检出/下载脚本代码"
    echo "3. 重新运行安装脚本："
    echo "   ./run_install_docker.sh"
    echo "-----------------------------------------------------------"
    
    read -p "是否忽略警告并继续运行？(y/n): " CONTINUE_RUN
    if [[ ! "$CONTINUE_RUN" =~ ^[Yy]$ ]]; then
        info "已取消运行"
        exit 0
    fi
fi

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
else
    # 尝试使用 uname 作为备选方案
    OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

# 根据操作系统选择对应的安装脚本
case "$OS_NAME" in
    "centos"|"rhel"|"almalinux"|"rocky")
        LOCAL_SCRIPT_NAME="docker/centos_install_docker.sh"
        info "检测到操作系统为 CentOS/RHEL 系列 ($OS_NAME)"
        ;;
    "ubuntu"|"debian")
        LOCAL_SCRIPT_NAME="docker/ubuntu_install_docker.sh"
        info "检测到操作系统为 Ubuntu/Debian 系列 ($OS_NAME)"
        ;;
    *)
        # 如果无法自动识别，尝试询问用户
        warning "无法自动识别操作系统或不支持的系统: $OS_NAME"
        echo "请手动选择操作系统类型："
        echo "1. CentOS/RHEL"
        echo "2. Ubuntu/Debian"
        read -p "请输入选项 (1/2): " CHOICE
        
        case "$CHOICE" in
            1)
                LOCAL_SCRIPT_NAME="docker/centos_install_docker.sh"
                ;;
            2)
                LOCAL_SCRIPT_NAME="docker/ubuntu_install_docker.sh"
                ;;
            *)
                error "无效的选项"
                ;;
        esac
        ;;
esac

info "使用本地Docker安装脚本: $LOCAL_SCRIPT_NAME"

# 检查本地脚本是否存在
if [ ! -f "$LOCAL_SCRIPT_NAME" ]; then
    error "本地脚本文件 $LOCAL_SCRIPT_NAME 不存在"
fi

# 设置可执行权限
info "设置可执行权限..."
chmod +x "$LOCAL_SCRIPT_NAME"

# 执行安装脚本
info "开始执行Docker安装脚本..."
info "注意：安装过程可能需要root权限，如果需要会自动请求"
echo "-----------------------------------------------------------"
./$LOCAL_SCRIPT_NAME

# 检查安装脚本的退出状态
if [ $? -eq 0 ]; then
    info "Docker安装脚本执行完成"
    
    # 询问用户是否安装Portainer
    read -p "是否安装Portainer容器管理界面？(y/n): " INSTALL_PORTAINER
    
    if [[ "$INSTALL_PORTAINER" =~ ^[Yy]$ ]]; then
        info "开始安装Portainer..."
        docker run -d --restart=always --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock registry.cn-hangzhou.aliyuncs.com/xfg-studio/portainer:latest
        
        if [ $? -eq 0 ]; then
            info "Portainer安装成功！"
            warning "重要提示：请确保您的云服务器已开放9000端口！"
            echo "-----------------------------------------------------------"
            echo "Portainer访问方式："
            echo "1. 通过公网访问：http://您的服务器公网IP:9000"
            echo "2. 首次访问需要设置管理员账号和密码"
            echo "3. 登录后即可通过Web界面管理Docker容器"
            echo "-----------------------------------------------------------"
            info "您可以使用Portainer来方便地管理Docker容器、镜像、网络和卷等资源"
        else
            warning "Portainer安装失败，请手动安装或检查Docker状态"
        fi
    else
        info "用户选择不安装Portainer"
    fi
else
    error "Docker安装脚本执行失败，请查看上面的错误信息"
fi
