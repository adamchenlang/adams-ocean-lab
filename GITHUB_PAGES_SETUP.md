# 🚀 GitHub Pages 部署指南

## 为什么选择GitHub Pages？

✅ **完全免费** - 无限流量
✅ **自动部署** - Push即部署
✅ **支持自定义域名** - laputasky.com
✅ **免费SSL证书** - 自动HTTPS
✅ **全球CDN** - 快速访问
✅ **零维护** - 无需管理服务器

---

## 📋 部署步骤

### Step 1: 创建GitHub仓库

```bash
# 1. 初始化Git（如果还没有）
cd /Users/liangchen/work/hangout/blogger
git init
git add .
git commit -m "Initial commit: Adam's Ocean Lab"

# 2. 在GitHub创建仓库
# 访问: https://github.com/new
# 仓库名: adams-ocean-lab
# 设置为Public

# 3. 推送代码
git remote add origin https://github.com/YOUR_USERNAME/adams-ocean-lab.git
git branch -M main
git push -u origin main
```

### Step 2: 启用GitHub Pages

1. 访问仓库的 **Settings** → **Pages**
2. **Source**: 选择 "GitHub Actions"
3. 保存

### Step 3: 配置自定义域名

#### 在GitHub设置

1. 在 **Settings** → **Pages** → **Custom domain**
2. 输入: `laputasky.com`
3. 点击 **Save**
4. 勾选 **Enforce HTTPS**（等DNS生效后）

#### 在GoDaddy配置DNS

登录GoDaddy，更新DNS记录：

**删除旧的A记录**，添加新的：

```
类型: A
名称: @
值: 185.199.108.153
TTL: 600

类型: A
名称: @
值: 185.199.109.153
TTL: 600

类型: A
名称: @
值: 185.199.110.153
TTL: 600

类型: A
名称: @
值: 185.199.111.153
TTL: 600

类型: CNAME
名称: www
值: YOUR_USERNAME.github.io
TTL: 600
```

### Step 4: 验证部署

```bash
# 推送代码触发部署
git add .
git commit -m "Update content"
git push

# 查看部署状态
# 访问: https://github.com/YOUR_USERNAME/adams-ocean-lab/actions
```

等待2-3分钟，访问：
- https://YOUR_USERNAME.github.io/adams-ocean-lab
- https://laputasky.com（DNS生效后）

---

## 🎨 添加CMS编辑功能

### 使用Decap CMS（已配置）

访问: `https://laputasky.com/admin`

#### 设置GitHub OAuth

1. 访问 https://github.com/settings/developers
2. 点击 **New OAuth App**
3. 填写：
   - **Application name**: Adam's Ocean Lab CMS
   - **Homepage URL**: https://laputasky.com
   - **Authorization callback URL**: https://api.netlify.com/auth/done
4. 获取 **Client ID** 和 **Client Secret**

#### 使用Netlify作为认证代理（免费）

1. 访问 https://app.netlify.com
2. 连接你的GitHub仓库
3. 在 **Site settings** → **Identity** → 启用
4. 在 **Services** → **Git Gateway** → 启用
5. 添加GitHub OAuth credentials

---

## 🔄 日常工作流程

### 方式1: 本地编辑（推荐给开发者）

```bash
# 1. 编辑文章
code src/content/blog/new-post.md

# 2. 本地预览
npm run dev

# 3. 提交并部署
git add .
git commit -m "Add new post"
git push

# 4. 自动部署到laputasky.com
```

### 方式2: CMS编辑（推荐给非技术用户）

```
1. 访问 https://laputasky.com/admin
2. 用GitHub登录
3. 点击 "New Blog Post"
4. 编写内容
5. 点击 "Publish"
6. 自动部署！
```

---

## 💰 成本对比

### GitHub Pages
- **托管**: $0/月
- **SSL证书**: $0/月
- **CDN**: $0/月
- **带宽**: 无限制
- **总计**: **$0/月** ✅

### OCI（当前方案）
- **服务器**: 免费层或付费
- **维护时间**: 需要
- **SSL配置**: 手动
- **部署**: 手动或CI/CD
- **总计**: 时间成本 + 可能的费用

---

## 🎯 推荐选择

### 选GitHub Pages如果：
- ✅ 只需要静态博客
- ✅ 想要零维护
- ✅ 想要自动部署
- ✅ 不需要后端功能

### 保留OCI如果：
- ✅ 需要后端API
- ✅ 需要数据库
- ✅ 需要服务器端功能
- ✅ 想学习DevOps

---

## 🚀 下一步

### 立即开始（推荐）

```bash
# 1. 创建GitHub仓库
# 2. Push代码
git push

# 3. 等待自动部署
# 4. 配置DNS
# 5. 完成！
```

### 或者两者都用

- **GitHub Pages**: 托管博客（laputasky.com）
- **OCI**: 运行其他服务（API、数据库等）

---

## 📞 需要帮助？

1. **GitHub Actions失败**: 查看Actions标签页的日志
2. **域名不工作**: 等待DNS传播（最多48小时）
3. **SSL证书问题**: 确保DNS正确指向GitHub
4. **CMS登录问题**: 检查OAuth配置

---

**推荐**: 先用GitHub Pages部署博客，简单快速。以后如果需要后端功能，再考虑OCI或其他方案。

**当前状态**: 
- ✅ GitHub Actions配置已创建
- ✅ CNAME文件已创建
- ✅ Decap CMS已配置
- ⏳ 等待你创建GitHub仓库并push

准备好了吗？运行 `git init` 开始吧！🚀
