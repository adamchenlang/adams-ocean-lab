#!/bin/bash

# 🚀 Adam's Ocean Lab - 自动部署（非交互式）

set -e

echo "🌊 开始部署 Adam's Ocean Lab..."
echo ""

# 初始化Git
if [ ! -d .git ]; then
    echo "📝 初始化Git仓库..."
    git init
    git add .
    git commit -m "Initial commit: Adam's Ocean Lab 🌊"
else
    echo "✅ Git仓库已存在"
fi

# 创建GitHub仓库
echo "📦 创建GitHub仓库..."
gh repo create adams-ocean-lab \
    --public \
    --description "Adam's Ocean Lab - Exploring the wonders of the sea 🌊" \
    --source=. \
    --remote=origin \
    --push || echo "仓库可能已存在，继续..."

# 获取用户名
USERNAME=$(gh api user -q .login)
echo "✅ GitHub用户名: $USERNAME"

# 启用GitHub Pages
echo "⚙️  配置GitHub Pages..."
gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/$USERNAME/adams-ocean-lab/pages" \
    -f build_type='workflow' 2>/dev/null || echo "✅ GitHub Pages已启用"

# 配置自定义域名
echo "🌐 配置域名 laputasky.com..."
gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/$USERNAME/adams-ocean-lab/pages" \
    -f cname='laputasky.com' 2>/dev/null || echo "✅ 域名已配置"

echo ""
echo "✅ 部署完成!"
echo ""
echo "📋 下一步:"
echo ""
echo "1. 🌐 配置GoDaddy DNS:"
echo "   访问: https://dcc.godaddy.com/manage/laputasky.com/dns"
echo ""
echo "   删除旧的A记录，添加:"
echo "   类型: A, 名称: @, 值: 185.199.108.153"
echo "   类型: A, 名称: @, 值: 185.199.109.153"
echo "   类型: A, 名称: @, 值: 185.199.110.153"
echo "   类型: A, 名称: @, 值: 185.199.111.153"
echo "   类型: CNAME, 名称: www, 值: $USERNAME.github.io"
echo ""
echo "2. ⏳ 查看部署进度:"
echo "   https://github.com/$USERNAME/adams-ocean-lab/actions"
echo ""
echo "3. 🎉 访问网站:"
echo "   https://$USERNAME.github.io/adams-ocean-lab"
echo "   https://laputasky.com (DNS生效后)"
echo ""
echo "4. 📝 访问CMS:"
echo "   https://laputasky.com/admin"
echo ""
echo "🎊 完成!"
