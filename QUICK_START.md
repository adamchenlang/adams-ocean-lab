# 🚀 Adam's Zone - 快速开始指南

## 📋 完整流程概览

```
原网站 → HTTrack复制 → 转换为Astro → 部署到OCI → 绑定域名 → 配置SSL
```

---

## 🎯 Step-by-Step 执行步骤

### Step 1: 初始化项目 (5分钟)

```bash
cd /Users/liangchen/work/hangout/blogger

# 运行初始化脚本
./setup.sh

# 等待安装完成...
```

**预期结果**: Astro项目创建完成，依赖安装完毕

---

### Step 2: 复制现有网站内容 (10-30分钟)

```bash
# 安装HTTrack（如果未安装）
brew install httrack

# 运行迁移脚本
./migrate-site.sh

# 按提示输入要复制的网站URL
# 例如: https://your-old-site.com
```

**预期结果**: 网站内容下载到 `temp/original-site/` 目录

---

### Step 3: 转换内容为Markdown (5分钟)

```bash
# 安装jsdom
npm install jsdom

# 运行转换脚本
node convert-to-markdown.js
```

**预期结果**: HTML文件转换为Markdown，保存在 `src/content/blog/`

---

### Step 4: 整理内容和资源 (15-30分钟)

```bash
# 1. 复制图片和静态资源
cp -r temp/original-site/images public/images
cp -r temp/original-site/assets public/assets

# 2. 手动检查和编辑Markdown文件
# 使用VS Code或其他编辑器打开 src/content/blog/
# 调整frontmatter（标题、描述、标签、日期）

# 3. 更新Astro配置
# 编辑 astro.config.mjs，设置site为 https://laputasky.com
```

---

### Step 5: 本地测试 (10分钟)

```bash
# 启动开发服务器
npm run dev

# 在浏览器中访问 http://localhost:4321
# 检查:
# - 所有页面正常显示
# - 图片正常加载
# - 链接正常工作
# - 响应式设计正常
```

---

### Step 6: Docker本地测试 (5分钟)

```bash
# 构建并运行Docker容器
docker-compose up -d

# 访问 http://localhost:3000
# 验证生产环境配置

# 查看日志
docker-compose logs -f

# 停止容器
docker-compose down
```

---

### Step 7: 配置GoDaddy DNS (5分钟)

1. 登录 [GoDaddy DNS管理](https://dcc.godaddy.com/manage/laputasky.com/dns)

2. 添加A记录:
   ```
   类型: A
   名称: @
   值: 129.213.149.112
   TTL: 600
   ```

3. 添加CNAME记录（可选）:
   ```
   类型: CNAME
   名称: www
   值: laputasky.com
   TTL: 600
   ```

4. 等待DNS传播（5分钟-2小时）

5. 验证DNS:
   ```bash
   dig laputasky.com
   # 应该返回 129.213.149.112
   ```

---

### Step 8: 部署到OCI (10分钟)

```bash
# 部署博客
./deploy.sh

# 等待部署完成...
# 访问 http://129.213.149.112:8081 验证
```

**预期结果**: 博客成功部署到OCI，通过IP可以访问

---

### Step 9: 配置Nginx和SSL (15分钟)

```bash
# 方式1: 使用自动化脚本（推荐）
./setup-ssl.sh

# 方式2: 手动配置
ssh opc@129.213.149.112

# 安装Nginx和Certbot
sudo yum install -y nginx certbot python3-certbot-nginx

# 创建Nginx配置
sudo vi /etc/nginx/conf.d/laputasky.conf
# 粘贴配置（见MIGRATION_AND_DOMAIN_SETUP.md）

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx

# 获取SSL证书
sudo certbot --nginx -d laputasky.com -d www.laputasky.com

# 按提示输入邮箱并同意条款
```

**预期结果**: SSL证书获取成功，HTTPS可以访问

---

### Step 10: 最终验证 (5分钟)

```bash
# 1. 检查HTTPS访问
curl -I https://laputasky.com

# 2. 在浏览器中访问
# https://laputasky.com
# https://www.laputasky.com

# 3. 验证SSL证书
# 浏览器地址栏应显示锁图标

# 4. 运行健康检查
./health-check.sh

# 5. SSL评级测试（可选）
# 访问: https://www.ssllabs.com/ssltest/analyze.html?d=laputasky.com
```

---

## 📊 完整时间估算

| 步骤 | 时间 | 说明 |
|------|------|------|
| 1. 初始化项目 | 5分钟 | 自动化 |
| 2. 复制网站 | 10-30分钟 | 取决于网站大小 |
| 3. 转换内容 | 5分钟 | 自动化 |
| 4. 整理内容 | 15-30分钟 | 需要手动调整 |
| 5. 本地测试 | 10分钟 | 验证功能 |
| 6. Docker测试 | 5分钟 | 验证容器 |
| 7. DNS配置 | 5分钟 + 等待 | DNS传播需要时间 |
| 8. 部署OCI | 10分钟 | 自动化 |
| 9. SSL配置 | 15分钟 | 半自动化 |
| 10. 最终验证 | 5分钟 | 测试 |
| **总计** | **1.5-2小时** | 不含DNS等待时间 |

---

## 🔧 常用命令速查

### 本地开发
```bash
npm run dev          # 启动开发服务器
npm run build        # 构建生产版本
npm run preview      # 预览构建结果
```

### Docker
```bash
docker-compose up -d              # 启动容器
docker-compose logs -f            # 查看日志
docker-compose down               # 停止容器
docker-compose restart            # 重启容器
```

### 部署
```bash
./deploy.sh          # 部署到OCI
./health-check.sh    # 健康检查
./rollback.sh        # 回滚到上一版本
```

### OCI服务器管理
```bash
# SSH连接
ssh opc@129.213.149.112

# 查看容器
docker ps | grep adams-zone

# 查看日志
docker logs -f adams-zone-blog

# 重启容器
docker restart adams-zone-blog

# 查看Nginx日志
sudo tail -f /var/log/nginx/laputasky_access.log
sudo tail -f /var/log/nginx/laputasky_error.log

# 检查SSL证书
sudo certbot certificates

# 测试证书续期
sudo certbot renew --dry-run
```

---

## 📚 文档索引

- **DEVELOPMENT_PLAN.md** - 完整开发计划
- **MIGRATION_AND_DOMAIN_SETUP.md** - 迁移和域名配置详细指南
- **README.md** - 项目说明
- **OCI_CONFIG.md** - OCI配置参考

---

## ✅ 检查清单

### 开发阶段
- [ ] 项目初始化完成
- [ ] 原网站内容复制完成
- [ ] 内容转换为Markdown
- [ ] 静态资源复制完成
- [ ] 本地开发服务器运行正常
- [ ] Docker容器本地测试通过

### 部署阶段
- [ ] GoDaddy DNS配置完成
- [ ] DNS解析生效
- [ ] 博客部署到OCI成功
- [ ] 通过IP可以访问
- [ ] Nginx配置完成
- [ ] SSL证书获取成功

### 最终验证
- [ ] https://laputasky.com 可以访问
- [ ] https://www.laputasky.com 可以访问
- [ ] HTTP自动重定向到HTTPS
- [ ] 浏览器显示安全锁图标
- [ ] 所有页面正常加载
- [ ] 图片和资源正常显示
- [ ] 移动端显示正常
- [ ] SSL Labs评级A或A+
- [ ] 页面加载速度 < 2秒

---

## 🆘 需要帮助？

### 问题排查
1. 查看 **MIGRATION_AND_DOMAIN_SETUP.md** 的故障排查部分
2. 检查日志文件
3. 运行健康检查脚本

### 常见问题

**Q: DNS没有生效怎么办？**  
A: DNS传播需要时间，通常5分钟到2小时。使用 `dig laputasky.com @8.8.8.8` 检查。

**Q: SSL证书获取失败？**  
A: 确保DNS已解析到正确IP，80端口开放，Nginx配置正确。

**Q: 网站显示502错误？**  
A: 检查Docker容器是否运行：`docker ps | grep adams-zone`

**Q: 图片无法显示？**  
A: 检查图片路径，确保复制到了 `public/` 目录。

---

## 🎉 完成后

恭喜！你的博客现在已经：
- ✅ 使用现代化的Astro框架
- ✅ 部署在Oracle Cloud
- ✅ 绑定了自定义域名
- ✅ 配置了免费的SSL证书
- ✅ 支持自动HTTPS重定向
- ✅ 证书自动续期

享受你的新博客吧！🚀

---

**域名**: laputasky.com  
**服务器**: 129.213.149.112  
**框架**: Astro  
**SSL**: Let's Encrypt  
**创建日期**: 2025-10-20
