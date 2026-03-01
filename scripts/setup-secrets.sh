#!/bin/bash

# 🔐 批量设置仓库 Secrets 脚本

REPO="tigerbreak/openhands-resolver"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误：GITHUB_TOKEN 未设置"
    exit 1
fi

echo "🔐 为仓库 $REPO 设置 Secrets"
echo ""

# 提示输入 Secret 值
read -p "请输入 LLM_API_KEY: " LLM_API_KEY
read -p "请输入 LLM_BASE_URL (可选): " LLM_BASE_URL
read -p "请输入 PAT_TOKEN: " PAT_TOKEN
read -p "请输入 PAT_USERNAME: " PAT_USERNAME

# 使用 GitHub CLI 设置（如果可用）
if command -v gh &> /dev/null; then
    echo "✅ 使用 GitHub CLI 设置..."
    
    echo "$LLM_API_KEY" | gh secret set LLM_API_KEY --repo "$REPO"
    [ -n "$LLM_BASE_URL" ] && echo "$LLM_BASE_URL" | gh secret set LLM_BASE_URL --repo "$REPO"
    echo "$PAT_TOKEN" | gh secret set PAT_TOKEN --repo "$REPO"
    echo "$PAT_USERNAME" | gh secret set PAT_USERNAME --repo "$REPO"
    
    echo ""
    echo "✅ Secrets 设置完成"
    gh secret list --repo "$REPO"
else
    echo "❌ GitHub CLI 未安装"
    echo "请手动在网页中设置："
    echo "https://github.com/$REPO/settings/secrets/actions"
fi
