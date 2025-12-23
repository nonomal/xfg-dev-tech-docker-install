#!/bin/bash

# Set strict error handling
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "============================================="
echo "   Terminal AI Assistant Installer"
echo "============================================="
echo "Please select the tool you want to install:"
echo "1) Claude Code (Anthropic)"
echo "2) Open Code (SST)"
echo "============================================="

read -p "Enter your choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "Starting installation of Claude Code..."
        echo "Official Website: https://claude.com/product/claude-code"
        echo "---------------------------------------------"
        INSTALL_SCRIPT="$SCRIPT_DIR/terminal/claude-code-install.sh"
        ;;
    2)
        echo ""
        echo "Starting installation of Open Code..."
        echo "Official Website: https://opencode.ai/download"
        echo "---------------------------------------------"
        INSTALL_SCRIPT="$SCRIPT_DIR/terminal/open-code-install.sh"
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
    echo "Please visit the official documentation to learn how to use Claude Code:"
    echo "👉 https://claude.com/product/claude-code"
elif [ "$choice" == "2" ]; then
    echo "Please visit the official documentation to learn how to use Open Code:"
    echo "👉 https://opencode.ai/download"
fi
echo "============================================="
