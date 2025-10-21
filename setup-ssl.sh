#!/bin/bash

set -e

echo "🔒 Setting up SSL for laputasky.com on OCI..."

OCI_HOST="129.213.149.112"
OCI_USER="opc"
SSH_KEY="$HOME/.ssh/id_rsa"
DOMAIN="laputasky.com"
WWW_DOMAIN="www.laputasky.com"

# 检查DNS是否已解析
echo "🔍 Checking DNS resolution..."
if ! dig +short $DOMAIN @8.8.8.8 | grep -q "$OCI_HOST"; then
    echo "⚠️  Warning: DNS may not be fully propagated yet"
    echo "Current DNS result:"
    dig +short $DOMAIN @8.8.8.8
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📝 Creating Nginx configuration..."

# 创建Nginx配置
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
# 创建Nginx配置文件
sudo tee /etc/nginx/conf.d/laputasky.conf << 'EOF'
# HTTP配置 - 用于Let's Encrypt验证和重定向
server {
    listen 80;
    listen [::]:80;
    server_name laputasky.com www.laputasky.com;

    # Let's Encrypt验证目录
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # 临时允许HTTP访问（获取证书后会改为重定向）
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 创建certbot目录
sudo mkdir -p /var/www/certbot

# 测试Nginx配置
echo "Testing Nginx configuration..."
sudo nginx -t

# 重启Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

# 检查Nginx状态
sudo systemctl status nginx --no-pager

echo "✅ Nginx configuration created"
ENDSSH

echo ""
echo "🔐 Installing Certbot..."

# 安装Certbot
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
# 检查是否已安装
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    sudo yum install -y certbot python3-certbot-nginx
else
    echo "Certbot already installed"
fi

certbot --version
ENDSSH

echo ""
echo "📜 Obtaining SSL certificate..."
echo "You will be prompted to enter your email address"
echo ""

# 获取SSL证书
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
# 获取证书
sudo certbot --nginx \
    -d laputasky.com \
    -d www.laputasky.com \
    --non-interactive \
    --agree-tos \
    --redirect \
    --email YOUR_EMAIL@example.com

# 注意: 请在运行前修改上面的邮箱地址
# 或者使用交互模式:
# sudo certbot --nginx -d laputasky.com -d www.laputasky.com

echo "✅ SSL certificate obtained"
ENDSSH

echo ""
echo "🔄 Setting up auto-renewal..."

# 配置自动续期
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
# 测试自动续期
echo "Testing certificate renewal..."
sudo certbot renew --dry-run

# 检查续期定时任务
echo ""
echo "Checking renewal timer..."
sudo systemctl list-timers | grep certbot || echo "No certbot timer found, but renewal should work via cron"

echo "✅ Auto-renewal configured"
ENDSSH

echo ""
echo "🎉 SSL setup complete!"
echo ""
echo "🌐 Your site should now be available at:"
echo "   https://laputasky.com"
echo "   https://www.laputasky.com"
echo ""
echo "🔍 Verify SSL certificate:"
echo "   curl -I https://laputasky.com"
echo "   https://www.ssllabs.com/ssltest/analyze.html?d=laputasky.com"
echo ""
echo "📊 Check certificate expiry:"
echo "   ssh opc@129.213.149.112 'sudo certbot certificates'"
