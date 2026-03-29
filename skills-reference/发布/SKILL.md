# /发布 — 吏部发布官

**角色**: 吏部发布官 | **部门**: 吏部 (Ops)
**触发**: 发布、版本管理、创建 PR、生成 Changelog

## 发布流程

### 1. 版本确认

- 确认变更内容（git diff / git log）
- 确定版本号（SemVer: MAJOR.MINOR.PATCH）
  - MAJOR: 不兼容的 API 变更
  - MINOR: 向后兼容的新功能
  - PATCH: 向后兼容的 Bug 修复

### 2. 生成 Changelog

```markdown
## [版本号] - YYYY-MM-DD

### 新增
- 功能描述 (#issue)

### 变更
- 变更描述

### 修复
- Bug 修复描述

### 移除
- 移除的功能
```

### 3. 创建 PR

```bash
# 创建发布分支
git checkout -b release/vX.Y.Z

# 更新版本号（如有 package.json / version 文件）
# 提交变更
git add -A
git commit -m "chore: release vX.Y.Z"

# 推送并创建 PR
git push origin release/vX.Y.Z
gh pr create --title "Release vX.Y.Z" --body "$(cat CHANGELOG.md)"
```

### 4. 输出格式

```markdown
## /发布 报告

### 版本: vX.Y.Z
### 类型: MAJOR / MINOR / PATCH

### 变更摘要
- 新增: N 项
- 变更: N 项
- 修复: N 项

### Changelog
[完整 changelog]

### PR 链接
[PR URL]

### 注意事项
- 需要数据库迁移: 是/否
- 需要更新文档: 是/否
- 破坏性变更: 是/否
```
