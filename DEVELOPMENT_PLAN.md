# 🚀 Adam's Zone - 博客开发与部署计划

## 📋 项目概述

**项目名称**: Adam's Zone  
**技术栈**: Astro + TypeScript + Tailwind CSS  
**部署目标**: Oracle Cloud Infrastructure (OCI)  
**容器化**: Docker + Docker Compose  

---

## 🎯 开发阶段

### Phase 1: 项目初始化 (Day 1)

#### 1.1 创建Astro项目
```bash
cd /Users/liangchen/work/hangout/blogger
npm create astro@latest . -- --template blog --typescript strict
```

#### 1.2 安装依赖
```bash
npm install
npm install -D @astrojs/tailwind tailwindcss
npm install -D @astrojs/sitemap
npm install -D @astrojs/rss
```

#### 1.3 项目结构
```
blogger/
├── src/
│   ├── components/      # 可复用组件
│   ├── layouts/         # 页面布局
│   ├── pages/           # 路由页面
│   │   ├── index.astro  # 首页
│   │   ├── blog/        # 博客文章
│   │   ├── about.astro  # 关于页面
│   │   └── rss.xml.js   # RSS订阅
│   ├── content/         # Markdown文章
│   │   └── blog/
│   └── styles/          # 全局样式
├── public/              # 静态资源
├── astro.config.mjs     # Astro配置
├── tailwind.config.cjs  # Tailwind配置
├── tsconfig.json        # TypeScript配置
├── Dockerfile           # Docker镜像
├── docker-compose.yml   # 本地开发
└── .dockerignore        # Docker忽略文件
```

---

### Phase 2: 功能开发 (Day 2-3)

#### 2.1 核心功能
- [x] 博客文章列表页
- [x] 文章详情页
- [x] 标签分类系统
- [x] 搜索功能
- [x] 暗色模式切换
- [x] 响应式设计

#### 2.2 SEO优化
- [x] Meta标签优化
- [x] Open Graph支持
- [x] Twitter Cards
- [x] Sitemap生成
- [x] RSS订阅

#### 2.3 性能优化
- [x] 图片优化（Astro Image）
- [x] 代码分割
- [x] 静态生成
- [x] 预加载关键资源

---

## 🐳 Docker化 (Day 4)

### 3.1 多阶段构建Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 3.2 Nginx配置

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### 3.3 Docker Compose (本地开发)

```yaml
version: '3.8'

services:
  blog:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    volumes:
      - ./src:/app/src:ro
      - ./public:/app/public:ro
    environment:
      - NODE_ENV=development
    restart: unless-stopped
```

### 3.4 .dockerignore

```
node_modules
dist
.git
.gitignore
.env
.env.local
*.log
.DS_Store
.vscode
.idea
README.md
```

---

## ☁️ OCI部署 (Day 5)

### 4.1 OCI服务器信息

**服务器IP**: `129.213.149.112`  
**SSH用户**: `opc`  
**容器名称**: `adams-zone-blog`  
**端口映射**: `8081:80` (避免与n8n冲突)

### 4.2 部署脚本

#### deploy.sh
```bash
#!/bin/bash

set -e

echo "🚀 Deploying Adam's Zone to OCI..."

# Configuration
OCI_HOST="129.213.149.112"
OCI_USER="opc"
SSH_KEY="~/.ssh/id_rsa"
CONTAINER_NAME="adams-zone-blog"
IMAGE_NAME="adams-zone:latest"
PORT="8081"

# Build Docker image locally
echo "📦 Building Docker image..."
docker build -t $IMAGE_NAME .

# Save image to tar
echo "💾 Saving Docker image..."
docker save $IMAGE_NAME | gzip > adams-zone.tar.gz

# Upload to OCI server
echo "📤 Uploading to OCI server..."
scp -i $SSH_KEY adams-zone.tar.gz $OCI_USER@$OCI_HOST:/tmp/

# Deploy on OCI server
echo "🔧 Deploying on OCI server..."
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
    # Load Docker image
    echo "Loading Docker image..."
    docker load < /tmp/adams-zone.tar.gz
    
    # Stop and remove existing container
    echo "Stopping existing container..."
    docker stop adams-zone-blog 2>/dev/null || true
    docker rm adams-zone-blog 2>/dev/null || true
    
    # Run new container
    echo "Starting new container..."
    docker run -d \
        --name adams-zone-blog \
        --restart unless-stopped \
        -p 8081:80 \
        adams-zone:latest
    
    # Cleanup
    rm /tmp/adams-zone.tar.gz
    
    echo "✅ Deployment complete!"
    echo "🌐 Blog available at: http://129.213.149.112:8081"
ENDSSH

# Cleanup local tar
rm adams-zone.tar.gz

echo "🎉 Deployment successful!"
```

#### rollback.sh
```bash
#!/bin/bash

set -e

OCI_HOST="129.213.149.112"
OCI_USER="opc"
SSH_KEY="~/.ssh/id_rsa"

echo "⏪ Rolling back to previous version..."

ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
    # Get previous image
    PREVIOUS_IMAGE=$(docker images adams-zone --format "{{.ID}}" | sed -n 2p)
    
    if [ -z "$PREVIOUS_IMAGE" ]; then
        echo "❌ No previous version found"
        exit 1
    fi
    
    # Stop current container
    docker stop adams-zone-blog
    docker rm adams-zone-blog
    
    # Run previous version
    docker run -d \
        --name adams-zone-blog \
        --restart unless-stopped \
        -p 8081:80 \
        $PREVIOUS_IMAGE
    
    echo "✅ Rollback complete!"
ENDSSH
```

### 4.3 OCI防火墙配置

```bash
# 在OCI服务器上执行
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

### 4.4 健康检查脚本

#### health-check.sh
```bash
#!/bin/bash

OCI_HOST="129.213.149.112"
PORT="8081"

echo "🏥 Checking blog health..."

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$OCI_HOST:$PORT)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Blog is healthy (HTTP $HTTP_CODE)"
    exit 0
else
    echo "❌ Blog is unhealthy (HTTP $HTTP_CODE)"
    exit 1
fi
```

---

## 📊 监控与维护

### 5.1 日志查看

```bash
# 查看容器日志
ssh opc@129.213.149.112 'docker logs adams-zone-blog'

# 实时日志
ssh opc@129.213.149.112 'docker logs -f adams-zone-blog'

# 最近100行日志
ssh opc@129.213.149.112 'docker logs --tail 100 adams-zone-blog'
```

### 5.2 容器管理

```bash
# 重启容器
ssh opc@129.213.149.112 'docker restart adams-zone-blog'

# 停止容器
ssh opc@129.213.149.112 'docker stop adams-zone-blog'

# 查看容器状态
ssh opc@129.213.149.112 'docker ps | grep adams-zone'

# 查看资源使用
ssh opc@129.213.149.112 'docker stats adams-zone-blog --no-stream'
```

### 5.3 备份策略

```bash
# 备份脚本
#!/bin/bash
BACKUP_DIR="/home/opc/backups/blog"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份Docker镜像
docker save adams-zone:latest | gzip > $BACKUP_DIR/adams-zone_$DATE.tar.gz

# 保留最近7天的备份
find $BACKUP_DIR -name "adams-zone_*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: $BACKUP_DIR/adams-zone_$DATE.tar.gz"
```

---

## 🔒 安全配置

### 6.1 HTTPS配置 (可选)

如果需要HTTPS，可以使用Nginx反向代理：

```nginx
server {
    listen 443 ssl http2;
    server_name blog.yourdomain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 6.2 环境变量管理

```bash
# .env.production
SITE_URL=http://129.213.149.112:8081
SITE_TITLE=Adam's Zone
SITE_DESCRIPTION=Personal tech blog
```

---

## 📝 开发工作流

### 7.1 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:4321
```

### 7.2 构建测试

```bash
# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

### 7.3 Docker本地测试

```bash
# 构建镜像
docker build -t adams-zone:test .

# 运行容器
docker run -p 3000:80 adams-zone:test

# 访问 http://localhost:3000
```

### 7.4 部署流程

```bash
# 1. 提交代码
git add .
git commit -m "feat: add new blog post"
git push

# 2. 构建并部署
./deploy.sh

# 3. 验证部署
./health-check.sh

# 4. 如果有问题，回滚
./rollback.sh
```

---

## 🎨 自定义配置

### 8.1 Astro配置 (astro.config.mjs)

```javascript
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'http://129.213.149.112:8081',
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

### 8.2 Tailwind配置

```javascript
module.exports = {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        secondary: '#8b5cf6',
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography')
  ]
};
```

---

## 📋 部署检查清单

### 部署前:
- [ ] 本地开发测试通过
- [ ] Docker镜像构建成功
- [ ] 本地Docker容器运行正常
- [ ] SSH连接到OCI服务器正常
- [ ] 端口8081未被占用

### 部署后:
- [ ] 容器成功启动 (`docker ps`)
- [ ] HTTP服务可访问 (http://129.213.149.112:8081)
- [ ] 首页正常加载
- [ ] 博客文章可访问
- [ ] 暗色模式切换正常
- [ ] 响应式设计在移动端正常
- [ ] RSS订阅可访问

### 性能优化:
- [ ] 图片已优化
- [ ] Gzip压缩已启用
- [ ] 静态资源缓存配置正确
- [ ] 页面加载时间 < 2秒

---

## 🚀 快速命令参考

```bash
# 本地开发
npm run dev

# 构建
npm run build

# Docker构建
docker build -t adams-zone:latest .

# 部署到OCI
./deploy.sh

# 健康检查
./health-check.sh

# 查看日志
ssh opc@129.213.149.112 'docker logs -f adams-zone-blog'

# 重启服务
ssh opc@129.213.149.112 'docker restart adams-zone-blog'
```

---

## 📚 相关文档

- [Astro官方文档](https://docs.astro.build)
- [Tailwind CSS文档](https://tailwindcss.com/docs)
- [Docker文档](https://docs.docker.com)
- [OCI部署参考](../automation/n8n/MANUAL_OCI_DEPLOYMENT.md)

---

## 🎯 下一步计划

1. **Phase 1**: 初始化项目并完成基础功能
2. **Phase 2**: Docker化并本地测试
3. **Phase 3**: 部署到OCI
4. **Phase 4**: 添加自定义域名和HTTPS
5. **Phase 5**: 集成评论系统（可选）
6. **Phase 6**: 添加分析工具（可选）

---

**创建日期**: 2025-10-20  
**最后更新**: 2025-10-20  
**维护者**: Adam
