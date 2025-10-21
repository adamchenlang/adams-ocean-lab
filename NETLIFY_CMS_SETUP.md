# 🔐 设置Google登录 - Netlify Identity

## 📋 步骤

### Step 1: 在Netlify部署网站

1. 访问: https://app.netlify.com
2. 点击 "Add new site" → "Import an existing project"
3. 选择 "Deploy with GitHub"
4. 授权Netlify访问GitHub
5. 选择仓库: `adamchenlang/adams-ocean-lab`
6. 构建设置：
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
7. 点击 "Deploy site"

### Step 2: 配置自定义域名

1. 在Netlify站点设置中
2. 进入 "Domain management"
3. 添加自定义域名: `adamchenlang.com`
4. Netlify会自动配置DNS（或使用你现有的GitHub Pages DNS）

### Step 3: 启用Netlify Identity

1. 在Netlify站点设置中
2. 进入 "Identity"
3. 点击 "Enable Identity"

### Step 4: 配置Google登录

1. 在Identity设置中
2. 进入 "Settings and usage"
3. 向下滚动到 "External providers"
4. 点击 "Add provider"
5. 选择 "Google"
6. 点击 "Enable"

### Step 5: 启用Git Gateway

1. 在Identity设置中
2. 进入 "Services" → "Git Gateway"
3. 点击 "Enable Git Gateway"
4. 这样CMS就可以直接编辑GitHub仓库

### Step 6: 邀请Adam

1. 在Identity标签页
2. 点击 "Invite users"
3. 输入Adam的邮箱
4. Adam会收到邀请邮件
5. 点击邮件中的链接设置账号

### Step 7: 更新CMS配置

需要更新 `public/admin/config.yml`:

```yaml
backend:
  name: git-gateway
  branch: master

# 移除 local_backend（生产环境不需要）

media_folder: "public/images/uploads"
public_folder: "/images/uploads"

collections:
  - name: "blog"
    label: "Blog Posts"
    folder: "src/content/blog"
    create: true
    slug: "{{slug}}"
    fields:
      - { label: "Title", name: "title", widget: "string" }
      - { label: "Description", name: "description", widget: "string" }
      - { label: "Publish Date", name: "pubDate", widget: "datetime" }
      - { label: "Hero Image", name: "heroImage", widget: "image" }
      - { label: "Tags", name: "tags", widget: "list" }
      - { label: "Body", name: "body", widget: "markdown" }
```

---

## 🎉 完成后

Adam可以：

1. 访问: https://adamchenlang.com/admin
2. 点击 "Login with Netlify Identity"
3. 选择 "Continue with Google"
4. 用Google账号登录
5. 创建/编辑博客文章
6. 点击 "Publish" 自动部署

---

## 💰 费用

- **Netlify Free Plan**:
  - ✅ 100GB带宽/月
  - ✅ 无限网站
  - ✅ 自动HTTPS
  - ✅ Identity: 1000个用户
  - ✅ 完全够用！

---

## 🔄 工作流程

```
Adam登录CMS → 编辑文章 → 点击Publish
    ↓
自动提交到GitHub
    ↓
GitHub Actions自动构建
    ↓
部署到GitHub Pages
    ↓
adamchenlang.com更新！
```

---

## 🆚 对比方案

### Netlify托管 + Identity（推荐）
- ✅ Google登录
- ✅ 简单配置
- ✅ 免费
- ✅ 自动部署

### GitHub Pages + OAuth App
- ❌ 只能GitHub登录
- ❌ 需要配置OAuth
- ❌ 更复杂

---

## 🚀 下一步

要我帮你：
1. 更新CMS配置文件？
2. 创建Netlify部署脚本？

或者你想先在Netlify网站上手动设置？
