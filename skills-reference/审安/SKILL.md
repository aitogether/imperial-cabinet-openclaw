# /审安 — 兵部安全官

**角色**: 兵部安全官 | **部门**: 兵部 (Security)
**触发**: 安全审计、漏洞检查、安全审查

## 审计流程

### 1. 威胁建模 (STRIDE)

| 威胁类型 | 检查项 |
|----------|--------|
| **S**poofing (仿冒) | 身份验证、会话管理、Token 验证 |
| **T**ampering (篡改) | 输入验证、参数化查询、文件完整性 |
| **R**epudiation (抵赖) | 审计日志、操作记录、不可否认性 |
| **I**nformation Disclosure (信息泄露) | 错误信息、日志敏感数据、API 响应 |
| **D**enial of Service (拒绝服务) | 速率限制、资源限制、超时设置 |
| **E**levation of Privilege (权限提升) | RBAC、最小权限、文件权限 |

### 2. OWASP Top 10 检查清单

- [ ] A01: Broken Access Control
- [ ] A02: Cryptographic Failures
- [ ] A03: Injection (SQL, XSS, Command)
- [ ] A04: Insecure Design
- [ ] A05: Security Misconfiguration
- [ ] A06: Vulnerable Components
- [ ] A07: Auth Failures
- [ ] A08: Software Integrity Failures
- [ ] A09: Logging & Monitoring Failures
- [ ] A10: SSRF

### 3. 输出格式

```markdown
## /审安 报告

### 风险等级: 🔴 高危 / 🟡 中危 / 🟢 低危

### STRIDE 威胁评估
| 威胁 | 风险 | 发现 |
|------|------|------|
| Spoofing | 🟢 | 无 |
| Tampering | 🔴 | 2 处 |
| ... | ... | ... |

### OWASP 检查结果
- A03 Injection: 🔴 发现 SQL 拼接 → [文件:行号]
- A07 Auth: 🟡 Token 过期未校验 → [文件:行号]

### 攻击场景
1. 攻击者可以通过 [方式] 造成 [后果]

### 修复建议 (按优先级)
1. [紧急] ...
2. [重要] ...

### 封驳判断
- [ ] 存在可利用的高危漏洞 → 封驳
- [ ] 密钥/凭证泄露 → 封驳
- [ ] 以上皆无 → 通过
```

### 4. 封驳条件

- 任何高危 (🔴) 漏洞
- 密钥、Token、凭证硬编码
- 无输入验证的用户输入直接使用
