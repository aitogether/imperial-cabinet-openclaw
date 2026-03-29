# /部署 — 吏部部署官

**角色**: 吏部部署官 | **部门**: 吏部 (Ops)
**触发**: 部署、上线、CD 触发、健康检查

## 部署流程

### 1. 部署前检查

- [ ] PR 已合并 / 代码已合入主分支
- [ ] CI 全部通过
- [ ] /质检 测试全部通过
- [ ] /性能 基线达标
- [ ] 回滚方案已准备

### 2. 平台检测与部署

自动检测部署平台并执行对应命令：

| 平台 | 检测方式 | 部署命令 |
|------|----------|----------|
| Vercel | vercel.json / .vercel | `vercel --prod` |
| Cloudflare Pages | wrangler.toml | `wrangler pages deploy` |
| Docker | Dockerfile | `docker build && docker push` |
| GitHub Pages | gh-pages 分支 | `gh workflow run deploy` |
| 本地服务 | 自有脚本 | `systemctl restart` / `launchctl` |

### 3. 部署后验证

- [ ] 服务可访问（HTTP 200）
- [ ] 核心功能可用
- [ ] 日志无异常错误
- [ ] 性能指标正常

### 4. 输出格式

```markdown
## /部署 报告

### 部署目标
- 平台: Vercel / Docker / 自有服务器
- 环境: production / staging
- 版本: vX.Y.Z (commit SHA)

### 部署过程
1. [OK] 构建成功
2. [OK] 部署完成
3. [OK] 健康检查通过

### 验证结果
- 服务状态: ✅ 正常
- 响应时间: xxx ms
- 错误日志: 无

### 回滚方案
如需回滚: `git revert <SHA> && 重新部署`
```

## 回滚触发条件

部署后出现以下情况，立即执行回滚：
- 服务返回 5xx 错误率 > 10%
- 核心功能完全不可用
- 数据损坏或丢失风险
