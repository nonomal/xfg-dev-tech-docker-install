#!/bin/bash

# Set strict error handling
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "============================================="
echo "   OpenClaw Installer"
echo "============================================="
echo "Starting installation of OpenClaw..."
echo "Local Install Script: $SCRIPT_DIR/openclaw/install.sh"
echo "---------------------------------------------"

INSTALL_SCRIPT="$SCRIPT_DIR/openclaw/install.sh"

# Check if script exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "Error: Installation script not found at $INSTALL_SCRIPT"
    exit 1
fi

# Make executable and run
chmod +x "$INSTALL_SCRIPT"
"$INSTALL_SCRIPT"

echo ""
echo "============================================="
echo "   Post-Installation Configuration"
echo "============================================="

# Detect shell configuration file
SHELL_CONFIG=""
SHELL_NAME=$(basename "$SHELL")

if [ "$SHELL_NAME" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    if [ "$(uname)" = "Darwin" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    else
        # Linux (CentOS, Ubuntu, etc.)
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    fi
fi

# Fallback detection
if [ -z "$SHELL_CONFIG" ] || [ ! -f "$SHELL_CONFIG" ]; then
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
fi

if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
    echo "Detected shell configuration file: $SHELL_CONFIG"
    
    echo "Refreshing system configuration in current script context..."
    if source "$SHELL_CONFIG"; then
         echo "✅ Configuration refreshed (for this script execution)."
    fi
else
    echo "⚠️  Could not automatically detect shell configuration file."
fi

echo ""
echo "============================================="
echo "   ⚠️  IMPORTANT: ACTION REQUIRED ⚠️"
echo "============================================="
echo "To make the installed command available in your current terminal,"
echo "you MUST execute the following command manually:"
echo ""
if [ -n "$SHELL_CONFIG" ]; then
    echo "    source $SHELL_CONFIG"
else
    echo "    source ~/.bashrc  # (or your shell's config file)"
fi
echo ""
echo "Alternatively, you can restart your terminal session."
echo "============================================="

echo ""
echo "============================================="
echo "   Next Steps"
echo "============================================="
echo "OpenClaw 安装完成！"
echo ""
echo "使用步骤:"
echo "1. 验证安装:"
echo "   openclaw --version"
echo ""
echo "2. 启动 OpenClaw:"
echo "   openclaw"
echo ""
echo "3. 常用命令:"
echo "   openclaw doctor   # 检查环境"
echo "   openclaw onboard  # 初始化设置"
echo ""
echo "详细文档: https://docs.openclaw.ai"
echo "============================================="
