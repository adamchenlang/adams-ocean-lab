#!/bin/bash

# 🚀 Adam's Ocean Lab - GitHub自动化部署脚本
# 这个脚本会自动创建GitHub仓库并配置GitHub Pages

set -e

echo "🌊 Adam's Ocean Lab - GitHub自动化设置"
echo "========================================"
echo ""

# 检查GitHub CLI是否已安装
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI未安装"
    echo "请运行: brew install gh"
    exit 1
fi

# 检查是否已登录
if ! gh auth status &> /dev/null; then
    echo "🔐 需要登录GitHub..."
    echo ""
    echo "请选择登录方式:"
    echo "1. 使用浏览器登录（推荐）"
    echo "2. 使用Personal Access Token"
    read -p "选择 (1/2): " choice
    
    if [ "$choice" = "1" ]; then
        gh auth login
    else
        echo ""
        echo "📝 创建Personal Access Token:"
        echo "1. 访问: https://github.com/settings/tokens/new"
        echo "2. 勾选权限: repo, workflow, admin:org"
        echo "3. 生成token并复制"
        echo ""
        gh auth login --with-token
    fi
else
    echo "✅ 已登录GitHub"
    gh auth status
fi

echo ""
echo "📦 准备创建仓库..."

# 询问仓库名称
read -p "仓库名称 (默认: adams-ocean-lab): " REPO_NAME
REPO_NAME=${REPO_NAME:-adams-ocean-lab}

# 询问是否公开
read -p "设为公开仓库? (y/n, 默认: y): " IS_PUBLIC
IS_PUBLIC=${IS_PUBLIC:-y}

if [ "$IS_PUBLIC" = "y" ]; then
    VISIBILITY="--public"
else
    VISIBILITY="--private"
fi

echo ""
echo "🔧 配置信息:"
echo "  仓库名: $REPO_NAME"
echo "  可见性: $([ "$IS_PUBLIC" = "y" ] && echo "公开" || echo "私有")"
echo "  域名: laputasky.com"
echo ""

read -p "确认创建? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "❌ 已取消"
    exit 0
fi

echo ""
echo "🚀 开始设置..."

# 初始化Git（如果还没有）
if [ ! -d .git ]; then
    echo "📝 初始化Git仓库..."
    git init
    git add .
    git commit -m "Initial commit: Adam's Ocean Lab 🌊"
fi

# 创建GitHub仓库
echo "📦 创建GitHub仓库..."
gh repo create $REPO_NAME $VISIBILITY \
    --description "Adam's Ocean Lab - Exploring the wonders of the sea 🌊" \
    --source=. \
    --remote=origin \
    --push

echo ""
echo "⚙️  配置GitHub Pages..."

# 获取仓库的完整名称
REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# 启用GitHub Pages
gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO_FULL/pages" \
    -f build_type='workflow' 2>/dev/null || echo "✅ GitHub Pages已启用"

# 配置自定义域名
echo "🌐 配置自定义域名..."
gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO_FULL/pages" \
    -f cname='laputasky.com' 2>/dev/null || echo "✅ 域名已配置"

echo ""
echo "✅ GitHub仓库创建成功!"
echo ""
echo "📋 下一步:"
echo ""
echo "1. 🌐 配置GoDaddy DNS:"
echo "   访问: https://dcc.godaddy.com/manage/laputasky.com/dns"
echo ""
echo "   删除旧的A记录，添加以下记录:"
echo ""
echo "   类型: A, 名称: @, 值: 185.199.108.153"
echo "   类型: A, 名称: @, 值: 185.199.109.153"
echo "   类型: A, 名称: @, 值: 185.199.110.153"
echo "   类型: A, 名称: @, 值: 185.199.111.153"
echo "   类型: CNAME, 名称: www, 值: $(gh api user -q .login).github.io"
echo ""
echo "2. ⏳ 等待部署完成 (2-3分钟):"
echo "   查看进度: https://github.com/$REPO_FULL/actions"
echo ""
echo "3. 🎉 访问你的网站:"
echo "   https://$(gh api user -q .login).github.io/$REPO_NAME"
echo "   https://laputasky.com (DNS生效后)"
echo ""
echo "4. 📝 访问CMS编辑器:"
echo "   https://laputasky.com/admin"
echo ""
echo "🎊 完成! 你的博客已经在部署中..."
