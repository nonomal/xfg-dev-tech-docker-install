#!/bin/bash

# Set strict error handling
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "============================================="
echo "   Terminal AI Assistant Installer"
echo "============================================="
echo "Please select the tool you want to install:"
echo "1) Open Code (SST) [推荐优先使用]"
echo "2) Claude Code (Anthropic)"
echo "============================================="

read -p "Enter your choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "Starting installation of Open Code..."
        echo "Official Website: https://opencode.ai/download"
        echo "---------------------------------------------"
        INSTALL_SCRIPT="$SCRIPT_DIR/terminal/open-code-install.sh"
        ;;
    2)
        echo ""
        echo "Starting installation of Claude Code..."
        echo "Official Website: https://claude.com/product/claude-code"
        echo "---------------------------------------------"
        INSTALL_SCRIPT="$SCRIPT_DIR/terminal/claude-code-install.sh"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

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
    
    # Check if we are in a subshell or sourced
    # If the script is run as ./terminal.sh, source won't affect parent shell.
    # We can try to exec a new shell to reload env, but that might be invasive.
    # Instead, we will provide a very clear instruction.
    
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

if [ "$choice" == "1" ]; then
    echo "Open Code 安装完成！"
    echo ""
    echo "使用步骤:"
    echo "1. 进入你的项目文件夹(任何一个都可以，也可以 mkdir 新建文件件，进入后它负责管理这个文件夹下的内容):"
    echo "   cd /dev-ops"
    echo ""
    echo "2. 启动 Open Code:"
    echo "   opencode"
    echo ""
    echo "3. 在 Open Code 中:"
    echo "   - 常用命令:"
    echo "     • /help - 查看帮助"
    echo "     • /models - 选择模型（免费模型、智谱AI GLM、小米AI 等）"
    echo "     • /clear - 清空对话"
    echo "     • /exit - 退出"
    echo "     • /login - 登录账号"
    echo "     • /logout - 退出登录"
    echo "     • /status - 查看状态"
    echo "     • /config - 查看配置"
    echo "     • /history - 查看历史记录"
    echo "     • /save - 保存对话"
    echo "     • /load - 加载对话"
    echo "     • /alias - 设置别名"
    echo "     • /theme - 切换主题"
    echo "     • /debug - 调试模式"
    echo ""
    echo "4. 配置自定义全局模型（方便配置代理地址）:"
    echo "   cd terminal"
    echo "   ./opencode.sh"
    echo "   然后编辑（输入 i 之后编辑，编辑后点击 esc，之后输入 :wq 退出）: vim /root/.config/opencode/opencode.json"
    echo ""
    echo "详细文档: https://opencode.ai/download"
    echo ""
    echo "============================================="
    echo "   所有可用命令汇总"
    echo "============================================="
    echo "基础命令:"
    echo "  /help      - 查看帮助信息"
    echo "  /models    - 选择模型（免费模型、智谱AI GLM、小米AI 等）"
    echo "  /clear     - 清空当前对话"
    echo "  /exit      - 退出 Open Code"
    echo ""
    echo "账号相关:"
    echo "  /login     - 登录账号"
    echo "  /logout    - 退出登录"
    echo "  /status    - 查看当前状态"
    echo ""
    echo "配置相关:"
    echo "  /config    - 查看当前配置"
    echo "  /alias     - 设置命令别名"
    echo "  /theme     - 切换主题"
    echo ""
    echo "历史记录:"
    echo "  /history   - 查看历史对话"
    echo "  /save      - 保存当前对话"
    echo "  /load      - 加载已保存的对话"
    echo ""
    echo "高级功能:"
    echo "  /debug     - 开启调试模式"
    echo "============================================="
    echo ""
elif [ "$choice" == "2" ]; then
    echo "Please visit the official documentation to learn how to use Claude Code:"
    echo "👉 https://claude.com/product/claude-code"
fi
echo "============================================="
