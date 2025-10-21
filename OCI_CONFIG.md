# OCI部署配置

## 服务器信息
- **IP**: 129.213.149.112
- **用户**: opc
- **端口**: 8081
- **容器名**: adams-zone-blog

## 防火墙配置
```bash
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

## 常用命令
```bash
# 查看日志
ssh opc@129.213.149.112 'docker logs -f adams-zone-blog'

# 重启
ssh opc@129.213.149.112 'docker restart adams-zone-blog'

# 状态检查
ssh opc@129.213.149.112 'docker ps | grep adams-zone'
```
