#!/bin/bash

set -e

echo "🌐 Website Migration Tool"
echo "========================"
echo ""

# 检查HTTrack是否安装
if ! command -v httrack &> /dev/null; then
    echo "❌ HTTrack is not installed"
    echo ""
    echo "Install HTTrack:"
    echo "  macOS: brew install httrack"
    echo "  Linux: sudo yum install httrack"
    exit 1
fi

echo "✅ HTTrack version: $(httrack --version 2>&1 | head -1)"
echo ""

# 获取源网站URL
read -p "Enter the website URL to copy (e.g., https://example.com): " SOURCE_URL

if [ -z "$SOURCE_URL" ]; then
    echo "❌ URL cannot be empty"
    exit 1
fi

echo ""
echo "📥 Downloading website content from: $SOURCE_URL"
echo "This may take several minutes..."
echo ""

# 创建临时目录
mkdir -p temp/original-site

# 使用HTTrack下载网站
httrack "$SOURCE_URL" \
    -O "./temp/original-site" \
    --depth=3 \
    --ext-depth=0 \
    --max-rate=500000 \
    --connection-per-second=5 \
    --sockets=4 \
    --keep-alive \
    --robots=0 \
    --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    --mirror \
    --quiet \
    -*.zip -*.tar.gz -*.pdf -*.exe \
    +*.html +*.css +*.js +*.jpg +*.jpeg +*.png +*.gif +*.svg +*.webp

echo ""
echo "✅ Download complete!"
echo ""
echo "📁 Downloaded files location: ./temp/original-site"
echo ""
echo "Next steps:"
echo "  1. Review downloaded content: ls -la temp/original-site"
echo "  2. Convert to Markdown: npm install jsdom && node convert-to-markdown.js"
echo "  3. Copy static assets: cp -r temp/original-site/images public/"
echo "  4. Test locally: npm run dev"
echo "  5. Deploy: ./deploy.sh"
