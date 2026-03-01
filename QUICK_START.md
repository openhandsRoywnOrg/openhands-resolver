# 🚀 OpenHands 模板仓库 - 快速开始指南

## 📋 目录

1. [设置 Secrets](#1-设置-secrets)
2. [使用模板创建新项目](#2-使用模板创建新项目)
3. [触发 OpenHands](#3-触发-openhands)
4. [批量管理](#4-批量管理)

---

## 1️⃣ 设置 Secrets

### 方式 A：通过 GitHub 网页（推荐）

#### 步骤：

1. **打开仓库设置**
   ```
   https://github.com/tigerbreak/openhands-resolver/settings/secrets/actions
   ```

2. **添加以下 Secrets**：

   | Secret 名称 | 说明 | 必填 |
   |-----------|------|------|
   | `LLM_API_KEY` | LLM API 密钥 | ✅ |
   | `LLM_BASE_URL` | LLM API 基础 URL | ❌ |
   | `PAT_TOKEN` | GitHub Personal Access Token | ✅ |
   | `PAT_USERNAME` | GitHub 用户名 | ✅ |

3. **点击 "New repository secret"**
   - 输入名称和值
   - 点击 "Add secret"

### 方式 B：使用 GitHub CLI

```bash
# 1. 登录 GitHub
gh auth login

# 2. 进入项目目录
cd /workspace/project/openhands-resolver

# 3. 设置 Secrets
gh secret set LLM_API_KEY
gh secret set LLM_BASE_URL
gh secret set PAT_TOKEN
gh secret set PAT_USERNAME

# 4. 验证
gh secret list
```

### 方式 C：使用自动化脚本

```bash
# 运行设置脚本
cd /workspace/project/openhands-resolver
./scripts/setup-secrets.sh
```

---

## 2️⃣ 使用模板创建新项目

### 方式 A：GitHub 网页

1. **访问模板仓库**
   ```
   https://github.com/tigerbreak/openhands-resolver
   ```

2. **点击 "Use this template" → "Create a new repository"**

3. **填写信息**
   - Repository name: `my-project-1`
   - Description: 项目描述
   - Public/Private: 选择可见性

4. **创建后配置 Secrets**
   - 进入新仓库的 Settings → Secrets and variables → Actions
   - 复制模板仓库的 Secrets

### 方式 B：GitHub CLI

```bash
# 从模板创建新仓库
gh repo create my-project-1 \
  --template tigerbreak/openhands-resolver \
  --private \
  --description "My new project"

# 配置 Secrets
cd my-project-1
gh secret set LLM_API_KEY
gh secret set PAT_TOKEN
```

### 方式 C：自动化工作流

1. **在模板仓库中触发**
   ```
   https://github.com/tigerbreak/openhands-resolver/actions/workflows/create-from-template.yml
   ```

2. **点击 "Run workflow"**
   - 输入新仓库名称
   - 选择是否私有

3. **等待完成**
   - 自动创建仓库
   - 自动创建初始 Issue

---

## 3️⃣ 触发 OpenHands

### 方式 A：添加标签

```bash
# 给 Issue 添加 fix-me 标签
gh issue edit <issue-number> --add-label "fix-me"
```

### 方式 B：评论 @openhands-agent

在 Issue 中评论：
```
@openhands-agent 请帮我解决这个问题
```

### 方式 C：创建 Issue 时直接添加标签

```bash
gh issue create \
  --title "Fix bug" \
  --body "Description" \
  --label "fix-me"
```

---

## 4️⃣ 批量管理

### 批量创建项目

```bash
#!/bin/bash

PROJECTS=("project-a" "project-b" "project-c")

for PROJECT in "${PROJECTS[@]}"; do
  gh repo create $PROJECT \
    --template tigerbreak/openhands-resolver \
    --private \
    --description "Auto project: $PROJECT"
  
  # 配置 Secrets
  (cd $PROJECT && gh secret set LLM_API_KEY)
done
```

### 批量配置 Secrets

```bash
# 使用脚本
./scripts/manage-secrets.sh batch project1 project2 project3

# 或使用 CLI
for REPO in project1 project2 project3; do
  gh secret set LLM_API_KEY --repo tigerbreak/$REPO
done
```

---

## 🔐 安全提示

1. **不要公开 Secrets**
   - 不要提交到代码库
   - 不要在 Issue/PR 中提及

2. **定期轮换**
   - 每 90 天更新 PAT
   - 监控 API 使用量

3. **权限控制**
   - 只授予必要的权限
   - 使用细粒度访问令牌

---

## 📞 常见问题

### Q: 全局 Secrets 在哪里设置？

A: GitHub 的全局 Secrets（账户级）需要通过以下方式设置：

1. **个人账号**：
   - Settings → Developer settings → Secrets and variables → Secrets
   - 或直接访问：https://github.com/settings/secrets

2. **组织账号**：
   - Organization Settings → Secrets and variables → Secrets

**注意**：全局 Secrets 不会自动同步到仓库，需要在每个仓库中单独配置或使用脚本批量设置。

### Q: 如何确保只有授权用户可以触发？

A: 模板已包含权限检查：
- 只允许 OWNER、COLLABORATOR、MEMBER 触发
- 普通用户的 Issue 不会执行 Action

### Q: 如何监控使用情况？

A: 
1. GitHub Actions: Settings → Actions → Usage
2. LLM API: 在提供商控制台查看
3. 设置预算告警

---

## 📚 更多资源

- [完整配置指南](SECRETS_GUIDE.md)
- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI 文档](https://cli.github.com/)

---

**最后更新**: 2026-03-01
