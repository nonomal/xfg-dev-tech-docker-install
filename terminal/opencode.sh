#!/bin/bash

# Check if user wants to create custom global model configuration
echo "是否要创建自定义全局模型配置？(y/n)"
read -p "请选择: " choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    # Create directory if it doesn't exist
    mkdir -p /root/.config/opencode
    
    # Copy opencode.json template
    cp "$(dirname "$0")/opencode.json" /root/.config/opencode/opencode.json
    
    echo ""
    echo "✓ 配置文件已创建: /root/.config/opencode/opencode.json"
    echo ""
    echo "请使用以下命令编辑配置文件:"
    echo "  vim /root/.config/opencode/opencode.json"
    echo ""
    echo "需要配置的内容:"
    echo "  - apiKey: 你的API密钥"
    echo "  - baseURL: 你的API基础URL"
    echo ""
    echo "可以按照文件中的案例添加其他需要的模型。"
    echo ""
fi

export OPENCODE_CONFIG="/root/.config/opencode/opencode.json"