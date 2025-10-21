# 🌐 网站迁移与域名配置指南

## 📋 项目目标

1. 使用HTTrack复制现有网站内容
2. 将内容整合到Astro博客模板
3. 部署到OCI
4. 绑定域名 laputasky.com
5. 配置SSL证书（Let's Encrypt）

---

## Phase 1: 使用HTTrack复制现有网站

### 1.1 安装HTTrack

#### macOS
```bash
brew install httrack
```

#### Linux (OCI服务器)
```bash
sudo yum install httrack  # CentOS/Oracle Linux
# 或
sudo apt-get install httrack  # Ubuntu/Debian
```

### 1.2 复制网站内容

```bash
cd /Users/liangchen/work/hangout/blogger

# 创建临时目录存放下载的内容
mkdir -p temp/original-site

# 使用HTTrack下载网站
# 替换 YOUR_WEBSITE_URL 为你要复制的网站地址
httrack "YOUR_WEBSITE_URL" \
  -O "./temp/original-site" \
  --depth=3 \
  --ext-depth=0 \
  --max-rate=500000 \
  --connection-per-second=5 \
  --sockets=4 \
  --keep-alive \
  --robots=0 \
  --user-agent="Mozilla/5.0" \
  --mirror \
  --quiet

# 参数说明:
# -O: 输出目录
# --depth=3: 下载深度为3层
# --ext-depth=0: 外部链接深度为0
# --max-rate: 限制下载速率(字节/秒)
# --connection-per-second: 每秒连接数
# --mirror: 镜像模式
```

### 1.3 HTTrack高级选项

```bash
# 如果需要更精细的控制
httrack "YOUR_WEBSITE_URL" \
  -O "./temp/original-site" \
  --depth=3 \
  --max-files=1000 \
  --max-time=3600 \
  --timeout=60 \
  --retries=3 \
  --cache=1 \
  --index \
  --verbose \
  -%v \
  -*.zip -*.tar.gz -*.pdf \
  +*.html +*.css +*.js +*.jpg +*.png +*.gif +*.svg
```

---

## Phase 2: 内容转换为Astro格式

### 2.1 创建转换脚本

```bash
# 创建内容转换脚本
cat > convert-to-markdown.js << 'EOF'
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

// 读取HTML文件并转换为Markdown
function convertHtmlToMarkdown(htmlPath) {
  const html = fs.readFileSync(htmlPath, 'utf-8');
  const dom = new JSDOM(html);
  const document = dom.window.document;
  
  // 提取标题
  const title = document.querySelector('h1, title')?.textContent || 'Untitled';
  
  // 提取主要内容
  const content = document.querySelector('article, main, .content, #content')?.innerHTML || document.body.innerHTML;
  
  // 生成frontmatter
  const frontmatter = `---
title: "${title}"
description: "Migrated from original site"
pubDate: "${new Date().toISOString().split('T')[0]}"
tags: ["migration"]
---

${content}
`;
  
  return frontmatter;
}

// 批量转换
const sourceDir = './temp/original-site';
const targetDir = './src/content/blog';

// 确保目标目录存在
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

// 遍历HTML文件
function processDirectory(dir) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      processDirectory(filePath);
    } else if (file.endsWith('.html')) {
      try {
        const markdown = convertHtmlToMarkdown(filePath);
        const mdFileName = file.replace('.html', '.md');
        const outputPath = path.join(targetDir, mdFileName);
        
        fs.writeFileSync(outputPath, markdown);
        console.log(`✅ Converted: ${file} -> ${mdFileName}`);
      } catch (error) {
        console.error(`❌ Error converting ${file}:`, error.message);
      }
    }
  });
}

processDirectory(sourceDir);
console.log('🎉 Conversion complete!');
EOF

chmod +x convert-to-markdown.js
```

### 2.2 安装依赖并运行转换

```bash
# 安装jsdom用于HTML解析
npm install jsdom

# 运行转换脚本
node convert-to-markdown.js
```

### 2.3 手动整理内容

转换后需要手动检查和调整：

1. **检查Markdown格式**
   ```bash
   ls -la src/content/blog/
   ```

2. **编辑frontmatter**
   - 更新标题和描述
   - 添加合适的标签
   - 设置正确的发布日期

3. **复制静态资源**
   ```bash
   # 复制图片和其他资源
   cp -r temp/original-site/images public/images
   cp -r temp/original-site/assets public/assets
   ```

---

## Phase 3: 域名配置

### 3.1 GoDaddy DNS配置

登录 GoDaddy 控制台，配置 DNS 记录：

#### A记录配置
```
类型: A
名称: @
值: 129.213.149.112
TTL: 600秒
```

#### CNAME记录配置（可选，用于www子域名）
```
类型: CNAME
名称: www
值: laputasky.com
TTL: 600秒
```

### 3.2 验证DNS解析

```bash
# 检查DNS是否生效（可能需要等待几分钟到几小时）
dig laputasky.com
dig www.laputasky.com

# 或使用nslookup
nslookup laputasky.com
```

---

## Phase 4: OCI服务器配置

### 4.1 安装Nginx（如果未安装）

```bash
ssh opc@129.213.149.112

# 安装Nginx
sudo yum install nginx -y

# 启动并设置开机自启
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 4.2 配置Nginx反向代理

```bash
# 创建Nginx配置文件
sudo tee /etc/nginx/conf.d/laputasky.conf << 'EOF'
# HTTP配置 - 重定向到HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name laputasky.com www.laputasky.com;

    # Let's Encrypt验证
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # 重定向到HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS配置
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name laputasky.com www.laputasky.com;

    # SSL证书配置（稍后由Certbot自动配置）
    ssl_certificate /etc/letsencrypt/live/laputasky.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/laputasky.com/privkey.pem;
    
    # SSL优化配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 安全头
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # 反向代理到Docker容器
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket支持（如果需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # 日志
    access_log /var/log/nginx/laputasky_access.log;
    error_log /var/log/nginx/laputasky_error.log;
}
EOF

# 测试Nginx配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

### 4.3 配置防火墙

```bash
# 开放HTTP和HTTPS端口
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 验证防火墙规则
sudo firewall-cmd --list-all
```

---

## Phase 5: SSL证书配置（Let's Encrypt）

### 5.1 安装Certbot

```bash
ssh opc@129.213.149.112

# 安装Certbot和Nginx插件
sudo yum install certbot python3-certbot-nginx -y
```

### 5.2 获取SSL证书

```bash
# 方式1: 使用Certbot自动配置（推荐）
sudo certbot --nginx -d laputasky.com -d www.laputasky.com

# 按照提示输入:
# 1. 邮箱地址（用于证书过期提醒）
# 2. 同意服务条款
# 3. 选择是否重定向HTTP到HTTPS（建议选择2）

# 方式2: 仅获取证书，手动配置
sudo certbot certonly --nginx -d laputasky.com -d www.laputasky.com
```

### 5.3 测试SSL配置

```bash
# 测试证书
sudo certbot certificates

# 测试自动续期
sudo certbot renew --dry-run
```

### 5.4 设置自动续期

```bash
# Certbot会自动创建续期定时任务
# 检查定时任务
sudo systemctl list-timers | grep certbot

# 或者手动添加cron任务
sudo crontab -e
# 添加以下行（每天凌晨2点检查续期）
0 2 * * * /usr/bin/certbot renew --quiet
```

---

## Phase 6: 更新Astro配置

### 6.1 更新astro.config.mjs

```javascript
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://laputasky.com',
  integrations: [
    tailwind(),
    sitemap()
  ],
  markdown: {
    shikiConfig: {
      theme: 'dracula',
      wrap: true
    }
  }
});
```

### 6.2 更新部署脚本

编辑 `deploy.sh`，确保域名配置正确：

```bash
# 在部署后添加域名验证
echo "🌐 Verifying domain..."
curl -I https://laputasky.com
```

---

## Phase 7: 完整部署流程

### 7.1 部署步骤

```bash
# 1. 复制网站内容
httrack "YOUR_WEBSITE_URL" -O "./temp/original-site"

# 2. 转换内容
node convert-to-markdown.js

# 3. 手动检查和调整内容
# 编辑 src/content/blog/ 中的文件

# 4. 复制静态资源
cp -r temp/original-site/images public/images

# 5. 本地测试
npm run dev
# 访问 http://localhost:4321

# 6. 构建
npm run build

# 7. Docker测试
docker-compose up -d
# 访问 http://localhost:3000

# 8. 部署到OCI
./deploy.sh

# 9. 验证部署
./health-check.sh
```

### 7.2 DNS和SSL配置（在OCI服务器上）

```bash
# 1. SSH到服务器
ssh opc@129.213.149.112

# 2. 配置Nginx
sudo vi /etc/nginx/conf.d/laputasky.conf
# 粘贴上面的配置

# 3. 测试Nginx配置
sudo nginx -t

# 4. 重启Nginx
sudo systemctl restart nginx

# 5. 获取SSL证书
sudo certbot --nginx -d laputasky.com -d www.laputasky.com

# 6. 验证HTTPS
curl -I https://laputasky.com
```

---

## Phase 8: 验证和测试

### 8.1 功能测试清单

- [ ] HTTP自动重定向到HTTPS
- [ ] www.laputasky.com 正常访问
- [ ] laputasky.com 正常访问
- [ ] SSL证书有效（浏览器显示锁图标）
- [ ] 所有页面正常加载
- [ ] 图片和静态资源正常显示
- [ ] 响应式设计在移动端正常
- [ ] 页面加载速度 < 2秒

### 8.2 SSL测试工具

```bash
# 使用SSL Labs测试（在线工具）
# 访问: https://www.ssllabs.com/ssltest/analyze.html?d=laputasky.com

# 使用命令行测试
openssl s_client -connect laputasky.com:443 -servername laputasky.com

# 检查证书有效期
echo | openssl s_client -servername laputasky.com -connect laputasky.com:443 2>/dev/null | openssl x509 -noout -dates
```

### 8.3 性能测试

```bash
# 测试响应时间
curl -o /dev/null -s -w "Time: %{time_total}s\n" https://laputasky.com

# 测试HTTPS性能
curl -o /dev/null -s -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nSSL: %{time_appconnect}s\nTotal: %{time_total}s\n" https://laputasky.com
```

---

## 🔧 故障排查

### 问题1: DNS未解析

**症状**: 无法访问域名

**解决方案**:
```bash
# 检查DNS传播
dig laputasky.com @8.8.8.8

# 清除本地DNS缓存
# macOS
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# 等待DNS传播（最多48小时，通常几分钟到几小时）
```

### 问题2: SSL证书获取失败

**症状**: Certbot报错

**解决方案**:
```bash
# 检查80端口是否开放
sudo netstat -tlnp | grep :80

# 检查防火墙
sudo firewall-cmd --list-all

# 手动验证域名指向
curl -I http://laputasky.com

# 查看Certbot日志
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

### 问题3: Nginx配置错误

**症状**: 502 Bad Gateway

**解决方案**:
```bash
# 检查Docker容器状态
docker ps | grep adams-zone

# 检查容器日志
docker logs adams-zone-blog

# 检查Nginx错误日志
sudo tail -f /var/log/nginx/laputasky_error.log

# 测试反向代理
curl http://localhost:8081
```

### 问题4: HTTPS重定向循环

**症状**: 浏览器显示"重定向次数过多"

**解决方案**:
```bash
# 检查Nginx配置中的proxy_set_header
# 确保包含: proxy_set_header X-Forwarded-Proto $scheme;

# 重启Nginx
sudo systemctl restart nginx
```

---

## 📊 监控和维护

### 证书续期监控

```bash
# 创建监控脚本
cat > /home/opc/check-ssl.sh << 'EOF'
#!/bin/bash
DOMAIN="laputasky.com"
DAYS_BEFORE_EXPIRY=30

EXPIRY_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_BEFORE_EXPIRY ]; then
    echo "⚠️  SSL certificate expires in $DAYS_LEFT days!"
    # 可以发送邮件或通知
else
    echo "✅ SSL certificate valid for $DAYS_LEFT more days"
fi
EOF

chmod +x /home/opc/check-ssl.sh

# 添加到cron（每周检查）
crontab -e
0 9 * * 1 /home/opc/check-ssl.sh
```

### 日志轮转

```bash
# Nginx日志轮转已自动配置
# 检查配置
cat /etc/logrotate.d/nginx
```

---

## 📝 快速命令参考

```bash
# 复制网站
httrack "URL" -O "./temp/original-site"

# 转换内容
node convert-to-markdown.js

# 部署
./deploy.sh

# 配置SSL
ssh opc@129.213.149.112 'sudo certbot --nginx -d laputasky.com -d www.laputasky.com'

# 检查SSL
curl -I https://laputasky.com

# 查看日志
ssh opc@129.213.149.112 'sudo tail -f /var/log/nginx/laputasky_access.log'

# 续期测试
ssh opc@129.213.149.112 'sudo certbot renew --dry-run'
```

---

## 🎯 完成检查清单

### 迁移阶段
- [ ] HTTrack成功下载原网站内容
- [ ] 内容转换为Markdown格式
- [ ] 静态资源复制到public目录
- [ ] 本地预览正常

### 部署阶段
- [ ] Docker镜像构建成功
- [ ] 容器在OCI上运行正常
- [ ] 通过IP地址可以访问

### 域名配置
- [ ] GoDaddy DNS A记录配置完成
- [ ] DNS解析生效
- [ ] Nginx反向代理配置完成

### SSL配置
- [ ] Let's Encrypt证书获取成功
- [ ] HTTPS访问正常
- [ ] HTTP自动重定向到HTTPS
- [ ] SSL Labs测试评级A或A+
- [ ] 自动续期配置完成

### 最终验证
- [ ] https://laputasky.com 正常访问
- [ ] https://www.laputasky.com 正常访问
- [ ] 浏览器显示安全锁图标
- [ ] 所有页面和资源正常加载
- [ ] 移动端显示正常

---

**创建日期**: 2025-10-20  
**域名**: laputasky.com  
**服务器**: 129.213.149.112  
**SSL提供商**: Let's Encrypt
