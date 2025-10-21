# 🌐 DNS配置指南 - adamchenlang.com

## ✅ 已完成

1. ✅ CNAME文件已更新为 `adamchenlang.com`
2. ✅ Astro配置已更新
3. ✅ GitHub Pages域名已配置
4. ✅ 代码已推送到GitHub

---

## 📋 下一步：配置GoDaddy DNS

### 访问DNS管理

https://dcc.godaddy.com/manage/adamchenlang.com/dns

### 配置步骤

#### 1. 删除现有的A记录（如果有）

删除所有指向旧IP的A记录

#### 2. 添加GitHub Pages的A记录

点击 "Add New Record"，添加以下4条A记录：

```
类型: A
名称: @
值: 185.199.108.153
TTL: 600秒

类型: A
名称: @
值: 185.199.109.153
TTL: 600秒

类型: A
名称: @
值: 185.199.110.153
TTL: 600秒

类型: A
名称: @
值: 185.199.111.153
TTL: 600秒
```

#### 3. 添加CNAME记录（www子域名）

```
类型: CNAME
名称: www
值: adamchenlang.github.io
TTL: 600秒
```

#### 4. 保存更改

点击 "Save" 保存所有DNS记录

---

## ⏳ 等待DNS生效

- **最快**: 几分钟
- **通常**: 1-2小时
- **最长**: 48小时

### 检查DNS是否生效

```bash
# 检查A记录
dig adamchenlang.com

# 检查CNAME记录
dig www.adamchenlang.com

# 或使用在线工具
# https://www.whatsmydns.net/#A/adamchenlang.com
```

---

## 🎉 访问你的网站

### 临时地址（立即可用）
https://adamchenlang.github.io/adams-ocean-lab

### 正式域名（DNS生效后）
- https://adamchenlang.com
- https://www.adamchenlang.com

### CMS编辑器
https://adamchenlang.com/admin

---

## 🔐 启用HTTPS

GitHub Pages会自动为你的域名申请免费SSL证书（Let's Encrypt）

### 步骤

1. 等待DNS完全生效
2. 访问: https://github.com/adamchenlang/adams-ocean-lab/settings/pages
3. 勾选 "Enforce HTTPS"
4. 等待几分钟，证书会自动配置

---

## ✅ 验证清单

- [ ] DNS A记录已添加（4条）
- [ ] DNS CNAME记录已添加（www）
- [ ] DNS已生效（dig命令验证）
- [ ] 网站可以通过 adamchenlang.com 访问
- [ ] HTTPS已启用
- [ ] www.adamchenlang.com 正常重定向

---

## 📊 当前状态

- ✅ **GitHub仓库**: https://github.com/adamchenlang/adams-ocean-lab
- ✅ **GitHub Pages**: 已启用
- ✅ **自定义域名**: adamchenlang.com
- ✅ **自动部署**: 已配置
- ⏳ **DNS配置**: 等待你在GoDaddy设置
- ⏳ **HTTPS**: DNS生效后自动配置

---

## 🎊 完成后

你的博客将在以下地址可用：

1. **主域名**: https://adamchenlang.com
2. **www子域名**: https://www.adamchenlang.com
3. **CMS编辑**: https://adamchenlang.com/admin

所有流量都会自动使用HTTPS加密！🔒
