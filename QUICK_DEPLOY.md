# 🚀 快速部署指南

## 方式1: 一键自动化（推荐）⭐⭐⭐⭐⭐

### 需要的Credentials

**只需要GitHub账号！** 不需要其他credential。

### 步骤

```bash
# 运行自动化脚本
./setup-github.sh
```

脚本会自动：
1. ✅ 检查GitHub CLI
2. ✅ 引导你登录GitHub
3. ✅ 创建GitHub仓库
4. ✅ 推送代码
5. ✅ 启用GitHub Pages
6. ✅ 配置自定义域名
7. ✅ 触发自动部署

### GitHub登录方式

#### 选项A: 浏览器登录（最简单）
- 脚本会打开浏览器
- 登录你的GitHub账号
- 授权GitHub CLI
- 完成！

#### 选项B: Personal Access Token
1. 访问: https://github.com/settings/tokens/new
2. Token名称: `Adam's Ocean Lab CLI`
3. 勾选权限:
   - ✅ `repo` (完整仓库访问)
   - ✅ `workflow` (GitHub Actions)
   - ✅ `admin:org` (组织管理，可选)
4. 点击 "Generate token"
5. 复制token
6. 在脚本提示时粘贴

---

## 方式2: 手动步骤

### Step 1: 登录GitHub CLI

```bash
# 浏览器登录
gh auth login

# 或使用token
gh auth login --with-token < your-token.txt
```

### Step 2: 创建仓库

```bash
# 初始化Git
git init
git add .
git commit -m "Initial commit"

# 创建并推送到GitHub
gh repo create adams-ocean-lab --public --source=. --remote=origin --push
```

### Step 3: 启用GitHub Pages

```bash
# 获取仓库名
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# 启用Pages
gh api --method POST "/repos/$REPO/pages" -f build_type='workflow'

# 配置域名
gh api --method PUT "/repos/$REPO/pages" -f cname='laputasky.com'
```

---

## 🌐 配置DNS（必需）

### GoDaddy DNS设置

访问: https://dcc.godaddy.com/manage/laputasky.com/dns

**删除现有的A记录**，添加：

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
值: YOUR_GITHUB_USERNAME.github.io
TTL: 600
```

---

## ✅ 验证部署

### 1. 检查GitHub Actions

```bash
# 查看部署状态
gh run list

# 查看最新运行的日志
gh run view --log
```

或访问: https://github.com/YOUR_USERNAME/adams-ocean-lab/actions

### 2. 测试网站

```bash
# 等待2-3分钟后
curl -I https://YOUR_USERNAME.github.io/adams-ocean-lab

# DNS生效后（可能需要几小时）
curl -I https://laputasky.com
```

### 3. 访问CMS

https://laputasky.com/admin

---

## 🔧 常用命令

### 查看仓库信息
```bash
gh repo view
gh repo view --web  # 在浏览器打开
```

### 查看部署状态
```bash
gh run list
gh run watch  # 实时查看
```

### 更新内容
```bash
git add .
git commit -m "Update content"
git push
# 自动触发部署！
```

### 查看Pages状态
```bash
gh api repos/:owner/:repo/pages
```

---

## 🎯 所需Credentials总结

### 必需
- ✅ **GitHub账号** - 免费注册
- ✅ **GoDaddy账号** - 你已有（管理域名）

### 可选
- 📝 **GitHub Personal Access Token** - 如果不想用浏览器登录

### 不需要
- ❌ AWS credentials
- ❌ OCI credentials  
- ❌ 信用卡
- ❌ 服务器密码

---

## 💡 提示

### 首次部署
- DNS传播需要时间（几分钟到48小时）
- 先用 `username.github.io/repo-name` 测试
- 确认工作后再配置DNS

### 日常使用
```bash
# 编辑文章
code src/content/blog/new-post.md

# 预览
npm run dev

# 部署
git add .
git commit -m "Add new post"
git push
```

### CMS编辑
- 访问 `/admin`
- 用GitHub登录
- 可视化编辑
- 自动提交到GitHub
- 自动部署！

---

## 🆘 故障排除

### GitHub CLI未安装
```bash
brew install gh
```

### 未登录
```bash
gh auth login
```

### 部署失败
```bash
gh run view --log  # 查看错误日志
```

### 域名不工作
- 检查DNS配置
- 等待DNS传播
- 确认GitHub Pages已启用HTTPS

---

## 🎊 准备好了吗？

运行这个命令开始：

```bash
./setup-github.sh
```

就这么简单！🚀
