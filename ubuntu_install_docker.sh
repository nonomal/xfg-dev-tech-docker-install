#!/bin/bash

# Ubuntu 24 安装Docker的Shell脚本
# 作者：xiaofuge
# 版本：1.0
# 创建日期：$(date +"%Y-%m-%d")

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

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    warning "此脚本需要root权限运行，将尝试使用sudo"
    # 如果不是root用户，则使用sudo重新运行此脚本
    exec sudo "$0" "$@"
    exit $?
fi

info "docker 环境安装脚本 By xiaofuge，建议使用 https://618.gaga.plus 优惠购买服务器，安装 Ubuntu 24.04 LTS 系统。"

# 显示系统信息
info "开始安装 Docker 环境..."
info "检查系统信息..."
echo "内核版本: $(uname -r)"
echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)"

# 网络连接检测
info "检测网络连接状态..."
NETWORK_TEST_PASSED=false

# 测试多个网络地址
TEST_URLS=(
    "https://www.baidu.com"
    "https://www.aliyun.com"
    "https://www.tsinghua.edu.cn"
    "https://www.ustc.edu.cn"
)

for url in "${TEST_URLS[@]}"; do
    if curl -fsSL --connect-timeout 5 --max-time 10 "$url" > /dev/null 2>&1; then
        info "网络连接正常，可以访问: $url"
        NETWORK_TEST_PASSED=true
        break
    fi
done

if [ "$NETWORK_TEST_PASSED" = false ]; then
    warning "网络连接检测失败，可能无法下载Docker相关文件"
    read -p "是否继续安装？(y/n): " CONTINUE_INSTALL
    if [[ ! "$CONTINUE_INSTALL" =~ ^[Yy]$ ]]; then
        info "用户选择退出安装"
        exit 0
    fi
else
    info "网络连接检测通过"
fi

# 检查是否已安装Docker
if command -v docker &> /dev/null; then
    INSTALLED_DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    warning "检测到系统已安装Docker，版本为: $INSTALLED_DOCKER_VERSION"
    
    # 询问用户是否卸载已安装的Docker
    read -p "是否卸载已安装的Docker并安装新版本？(y/n): " UNINSTALL_DOCKER
    
    if [[ "$UNINSTALL_DOCKER" =~ ^[Yy]$ ]]; then
        info "开始卸载已安装的Docker..."
        systemctl stop docker &> /dev/null
        apt-get remove -y docker-ce docker-ce-cli containerd.io docker docker-engine docker.io containerd runc &> /dev/null
        rm -rf /var/lib/docker
        rm -rf /var/lib/containerd
        info "Docker卸载完成"
    else
        info "用户选择保留已安装的Docker，退出安装程序"
        exit 0
    fi
fi

# 更新系统包
info "更新系统包..."
apt-get update -y || error "系统更新失败"

# 安装依赖包
info "安装Docker依赖包..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common || error "依赖包安装失败"

# 添加Docker GPG密钥
info "添加Docker GPG密钥..."
install -m 0755 -d /etc/apt/keyrings

# 尝试多个源下载GPG密钥（优先使用国内镜像源）
GPG_SUCCESS=false

# 优先尝试阿里云镜像源（国内用户推荐）
info "尝试从阿里云镜像下载GPG密钥..."
if curl -fsSL --connect-timeout 10 --max-time 30 https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
    GPG_SUCCESS=true
    info "从阿里云镜像成功下载GPG密钥"
else
    warning "从阿里云镜像下载GPG密钥失败，尝试清华源..."
    
    # 尝试清华源
    info "尝试从清华源下载GPG密钥..."
    if curl -fsSL --connect-timeout 10 --max-time 30 https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
        GPG_SUCCESS=true
        info "从清华源成功下载GPG密钥"
    else
        warning "从清华源下载GPG密钥失败，尝试中科大源..."
        
        # 尝试中科大源
        info "尝试从中科大源下载GPG密钥..."
        if curl -fsSL --connect-timeout 10 --max-time 30 https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
            GPG_SUCCESS=true
            info "从中科大源成功下载GPG密钥"
        else
            warning "从国内镜像源下载GPG密钥都失败，尝试官方源..."
            
            # 最后尝试官方源
            info "尝试从Docker官方下载GPG密钥..."
            if curl -fsSL --connect-timeout 10 --max-time 30 https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
                GPG_SUCCESS=true
                info "从Docker官方成功下载GPG密钥"
            fi
        fi
    fi
fi

if [ "$GPG_SUCCESS" = false ]; then
    error "从所有源下载GPG密钥都失败。\n\n建议解决方案：\n1. 检查网络连接和DNS设置\n2. 手动下载GPG密钥：\n   wget https://download.docker.com/linux/ubuntu/gpg -O docker.gpg\n   sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg docker.gpg\n3. 使用代理服务器后再运行脚本\n4. 稍后再试，可能是临时网络问题"
fi

chmod a+r /etc/apt/keyrings/docker.gpg

# 设置Docker仓库
info "设置Docker仓库..."

# 获取系统版本代号
UBUNTU_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
ARCH=$(dpkg --print-architecture)

# 优先使用国内镜像源（国内用户推荐）
info "优先使用国内镜像源设置Docker仓库..."

# 首先尝试阿里云镜像源
info "尝试阿里云镜像源..."
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $UBUNTU_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新apt包索引
info "更新apt包索引..."
if apt-get update -y; then
    info "阿里云镜像源设置成功"
else
    warning "阿里云镜像源更新失败，尝试清华源..."
    
    # 尝试清华源
    info "尝试清华源..."
    echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $UBUNTU_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    if apt-get update -y; then
        info "清华源设置成功"
    else
        warning "清华源更新失败，尝试中科大源..."
        
        # 尝试中科大源
        info "尝试中科大源..."
        echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $UBUNTU_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        if apt-get update -y; then
            info "中科大源设置成功"
        else
            warning "国内镜像源都无法连接，尝试官方源..."
            
            # 最后尝试官方源
            info "尝试Docker官方仓库..."
            echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            if apt-get update -y; then
                info "Docker官方仓库设置成功"
            else
                error "所有仓库源都无法连接，请检查网络连接或手动设置Docker仓库"
            fi
        fi
    fi
fi

# 更新apt包索引
info "更新apt包索引..."
apt-get update -y || error "更新apt包索引失败"

# 安装Docker CE
info "安装Docker CE..."
DOCKER_INSTALL_SUCCESS=false

# 尝试安装最新版本
if apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    DOCKER_INSTALL_SUCCESS=true
    info "Docker安装成功"
else
    warning "Docker最新版本安装失败，尝试安装指定版本..."
    
    # 获取可用的Docker版本
    info "获取可用的Docker版本..."
    apt-cache madison docker-ce | head -5
    
    # 尝试安装较新的稳定版本
    DOCKER_VERSIONS=("5:24.0.7-1~ubuntu.$(lsb_release -rs)~$(lsb_release -cs)" "5:23.0.6-1~ubuntu.$(lsb_release -rs)~$(lsb_release -cs)" "5:20.10.24-3~ubuntu.$(lsb_release -rs)~$(lsb_release -cs)")
    
    for version in "${DOCKER_VERSIONS[@]}"; do
        info "尝试安装Docker版本: $version"
        if apt-get install -y docker-ce=$version docker-ce-cli=$version containerd.io docker-buildx-plugin docker-compose-plugin; then
            DOCKER_INSTALL_SUCCESS=true
            info "Docker $version 安装成功"
            break
        else
            warning "Docker $version 安装失败"
        fi
    done
fi

if [ "$DOCKER_INSTALL_SUCCESS" = false ]; then
    error "Docker安装失败。\n\n建议解决方案：\n1. 检查网络连接和DNS设置\n2. 手动安装指定版本：\n   apt-cache madison docker-ce  # 查看可用版本\n   apt-get install -y docker-ce=<版本号> docker-ce-cli=<版本号> containerd.io\n3. 使用snap安装：sudo snap install docker\n4. 检查系统日志：journalctl -xe\n5. 稍后再试，可能是临时网络问题"
fi

# 启动Docker服务
info "启动Docker服务..."
systemctl start docker || error "Docker服务启动失败"

# 设置Docker开机自启
info "设置Docker开机自启..."
systemctl enable docker || error "设置Docker开机自启失败"

# 重启Docker服务
info "重启Docker服务..."
systemctl restart docker || error "Docker服务重启失败"

# 配置Docker镜像加速
info "配置Docker镜像加速..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.1panel.live",
    "https://docker.ketches.cn"
  ]
}
EOF

# 再次重启Docker服务以应用镜像加速配置
info "重启Docker服务以应用镜像加速配置..."
systemctl restart docker || error "应用镜像加速配置后Docker重启失败"

# 验证Docker安装
info "验证Docker安装..."
DOCKER_VERSION=$(docker --version)
echo "Docker版本: $DOCKER_VERSION"
DOCKER_COMPOSE_VERSION=$(docker compose version)
echo "Docker Compose版本: $DOCKER_COMPOSE_VERSION"

# 下载并安装 Docker Compose
info "下载 Docker Compose..."
# 指定路径【推荐】
curl -L "https://gitee.com/fustack/docker-compose/releases/download/v2.24.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

if [ $? -eq 0 ] && [ -s /usr/local/bin/docker-compose ]; then
    info "Docker Compose 下载成功，设置权限..."
    # 设置权限
    chmod +x /usr/local/bin/docker-compose
    
    if [ $? -ne 0 ]; then
        error "Docker Compose 权限设置失败"
    fi
else
    error "Docker Compose 下载失败"
fi

info "Docker环境安装完成！"
echo "=================================================="
echo "Docker安装成功！"
echo "=================================================="
info "镜像加速已配置为："
echo "  - https://docker.1ms.run"
echo "  - https://docker.1panel.live"
echo "  - https://docker.ketches.cn"

info "您的Docker已经安装完毕，版本为：$DOCKER_VERSION"

echo ""
echo "🚀 Docker常用命令："
echo "  docker --version          # 查看Docker版本"
echo "  docker ps                 # 查看运行中的容器"
echo "  docker images             # 查看本地镜像"
echo "  docker pull hello-world   # 拉取测试镜像"
echo "  docker run hello-world    # 运行测试容器"
echo ""
echo "📚 后续建议："
echo "  1. 运行 'docker run hello-world' 测试Docker是否正常工作"
echo "  2. 如需管理容器，可考虑安装Portainer"
echo "  3. 定期更新Docker：apt-get update && apt-get upgrade docker-ce"
echo ""
echo "🔗 如果镜像加速不可用，可访问：https://status.1panel.top/status/docker"
echo "   获取最新的镜像加速地址"
echo "=================================================="