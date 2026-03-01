# 🔐 OpenHands 全局 Secrets 配置指南

## 📋 目录

1. [个人全局 Secrets 设置](#1-个人全局-secrets-设置)
2. [使用模板创建新项目](#2-使用模板创建新项目)
3. [自动化工作流](#3-自动化工作流)
4. [安全最佳实践](#4-安全最佳实践)

---

## 1️⃣ 个人全局 Secrets 设置

### 方法一：通过 GitHub 网页设置（推荐）

#### 步骤：

1. **打开设置页面**
   - 点击右上角头像 → **Settings**
   - 或者访问：https://github.com/settings/secrets

2. **导航到 Secrets**
   - 左侧菜单：**Developer settings** → **Secrets and variables** → **Secrets**
   - 或者直接在设置中搜索 "Secrets"

3. **添加全局 Secrets**

   点击 **New repository secret** 或 **New organization secret**，添加以下 Secrets：

   | Secret 名称 | 说明 | 示例值 | 必填 |
   |-----------|------|--------|------|
   | `LLM_API_KEY` | LLM API 密钥 | `sk-xxxxxxxxxxxx` | ✅ |
   | `LLM_BASE_URL` | LLM API 基础 URL | `https://api.openai.com/v1` | ❌ |
   | `PAT_TOKEN` | Personal Access Token | `ghp_xxxxxxxxxxxx` | ✅ |
   | `PAT_USERNAME` | GitHub 用户名 | `tigerbreak` | ✅ |

4. **保存**
   - 点击 **Add secret** 保存

### 方法二：通过 GitHub CLI 设置

```bash
# 安装 GitHub CLI (如果未安装)
# macOS: brew install gh
# Ubuntu: sudo apt install gh
# Windows: winget install GitHub.cli

# 登录 GitHub
gh auth login

# 设置全局 Secrets（账户级）
# 注意：GitHub CLI 默认设置的是仓库级 Secrets
# 全局 Secrets 需要通过网页设置

# 查看当前配置
gh secret list
```

### 方法三：使用 PAT 和 API 设置

```bash
# 设置环境变量
export GITHUB_TOKEN="ghp_your_personal_access_token"

# 使用 API 设置（需要加密，比较复杂）
# 推荐使用网页方式设置全局 Secrets
```

---

## 2️⃣ 使用模板创建新项目

### 方法一：通过 GitHub 网页（手动）

1. **访问模板仓库**
   - 打开：https://github.com/tigerbreak/openhands-resolver

2. **使用模板创建**
   - 点击绿色按钮 **"Use this template"**
   - 选择 **"Create a new repository"**

3. **填写信息**
   - Repository name: `my-new-project`
   - Description: `My project description`
   - Public/Private: 选择可见性
   - ✅ Include all branches: 可选

4. **创建仓库**
   - 点击 **"Create repository from template"**

5. **配置 Secrets**
   - 进入新仓库 → Settings → Secrets and variables → Actions
   - 添加所需的 Secrets（从全局复制）

### 方法二：使用自动化工作流（推荐）⭐

1. **在模板仓库中触发工作流**
   - 打开：https://github.com/tigerbreak/openhands-resolver/actions
   - 选择 **"Create Project from Template"** 工作流
   - 点击 **"Run workflow"**

2. **填写参数**
   ```
   New repository name: my-project-1
   Project description: 我的项目描述
   Make repository private: false
   ```

3. **运行**
   - 点击 **"Run workflow"**
   - 等待工作流完成

4. **查看结果**
   - 工作流会创建新仓库
   - 自动创建初始 Issue（带 `fix-me` 标签）
   - 输出配置说明

### 方法三：使用 GitHub CLI

```bash
# 从模板创建新仓库
gh repo create my-new-project \
  --template tigerbreak/openhands-resolver \
  --public \
  --description "My new project"

# 克隆到本地
cd my-new-project
gh repo clone tigerbreak/my-new-project

# 配置 Secrets（需要手动输入）
gh secret set LLM_API_KEY
gh secret set LLM_BASE_URL
gh secret set PAT_TOKEN
gh secret set PAT_USERNAME

# 或者一次性设置
echo "your-api-key" | gh secret set LLM_API_KEY
echo "https://api.example.com" | gh secret set LLM_BASE_URL
```

---

## 3️⃣ 自动化工作流

### 工作流文件说明

模板仓库包含以下工作流：

#### 1. `openhands-resolver.yml`
- **触发条件**：Issue/PR 添加 `fix-me` 标签，或评论 `@openhands-agent`
- **功能**：调用 OpenHands 自动解决问题
- **权限检查**：只允许 OWNER/COLLABORATOR/MEMBER 触发

#### 2. `create-from-template.yml`
- **触发方式**：手动触发（workflow_dispatch）
- **功能**：从模板创建新仓库并初始化
- **输出**：新仓库 URL 和配置说明

### 使用示例

#### 场景 1：为老客户创建新项目

```bash
# 1. 触发工作流创建新仓库
# 在模板仓库的 Actions 页面触发

# 2. 等待工作流完成
# 新仓库已创建，包含初始 Issue

# 3. 在新仓库中配置 Secrets
# 可以手动配置或使用脚本批量配置
```

#### 场景 2：批量创建多个项目

```bash
#!/bin/bash

# 批量创建项目脚本
PROJECTS=("project-a" "project-b" "project-c")

for PROJECT in "${PROJECTS[@]}"; do
  echo "Creating $PROJECT..."
  
  gh repo create $PROJECT \
    --template tigerbreak/openhands-resolver \
    --private \
    --description "Auto-generated project: $PROJECT"
  
  # 等待仓库创建
  sleep 5
  
  echo "✅ Created $PROJECT"
done

echo "🎉 All projects created!"
```

---

## 4️⃣ 安全最佳实践

### 🔐 Secrets 管理

#### ✅ 推荐做法：

1. **使用全局 Secrets**
   - 在账户级别设置一次
   - 所有仓库可以继承（需要配置）

2. **定期轮换 Secrets**
   - 每 90 天更新一次 PAT
   - 监控 API 使用情况

3. **最小权限原则**
   - PAT 只授予必要的权限
   - 使用细粒度的访问令牌

4. **监控使用**
   - 定期检查 Actions 使用量
   - 设置预算告警

#### ❌ 避免做法：

1. **不要在代码中硬编码 Secrets**
   ```bash
   # ❌ 错误
   export API_KEY="sk-123456"
   
   # ✅ 正确
   export API_KEY="${{ secrets.LLM_API_KEY }}"
   ```

2. **不要提交 .env 文件**
   ```bash
   # .gitignore 中添加
   .env
   *.env
   ```

3. **不要公开分享 Secrets**
   - 不要在 Issue/PR 中提及
   - 不要在日志中打印

### 🛡️ 权限控制

#### 推荐的 PAT 权限：

```
✅ repo (Full control of private repositories)
✅ workflow (Update GitHub Action workflows)
✅ read:org (Read org membership)
✅ read:user (Read user profile)
✅ user:email (Read user email addresses)
```

#### 创建 PAT：

1. 访问：https://github.com/settings/tokens
2. 点击 **Generate new token (classic)**
3. 选择上述权限
4. 生成并保存（只显示一次！）

### 📊 监控和告警

#### 设置使用量监控：

1. **GitHub Actions 使用量**
   - Settings → Billing and plans → Actions
   - 设置预算上限

2. **LLM API 使用量**
   - 在 LLM 提供商控制台设置
   - 每日/每月预算上限

3. **告警通知**
   - 设置邮件通知
   - 集成 Slack/Discord 通知

---

## 🚀 快速开始

### 第一次使用：

```bash
# 1. 设置全局 Secrets（网页方式）
# 访问：https://github.com/settings/secrets

# 2. 创建 PAT（如果需要）
# 访问：https://github.com/settings/tokens

# 3. 测试模板
# 访问：https://github.com/tigerbreak/openhands-resolver
# 点击 "Use this template" 创建测试项目
```

### 日常使用：

```bash
# 创建新项目
gh repo create my-project \
  --template tigerbreak/openhands-resolver \
  --private

# 配置 Secrets
cd my-project
gh secret set LLM_API_KEY
gh secret set PAT_TOKEN

# 创建 Issue 并触发
gh issue create --title "Fix bug" --label "fix-me"
```

---

## 📞 常见问题

### Q1: 全局 Secrets 能自动同步到新仓库吗？

**A:** 不能直接同步。GitHub 的全局 Secrets 只在特定作用域有效：
- **账户级 Secrets**：只在个人账户的仓库中可用
- **组织级 Secrets**：只在组织内的仓库中可用

**解决方案**：
1. 使用自动化脚本复制 Secrets
2. 使用 GitHub CLI 批量设置
3. 使用工作流自动配置

### Q2: 如何批量管理多个项目的 Secrets？

**A:** 使用以下方法之一：

```bash
# 方法 1: GitHub CLI 批量设置
for REPO in repo1 repo2 repo3; do
  gh secret set LLM_API_KEY --body "your-key" --repo tigerbreak/$REPO
done

# 方法 2: 使用 API
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/tigerbreak/$REPO/actions/secrets/LLM_API_KEY
```

### Q3: 如何确保安全性？

**A:** 
1. ✅ 使用权限检查（已实现）
2. ✅ 定期轮换 Secrets
3. ✅ 监控使用量
4. ✅ 限制触发用户
5. ✅ 使用私有仓库（可选）

---

## 📚 相关资源

- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI 文档](https://cli.github.com/)
- [OpenHands 文档](https://docs.openhands.dev/)
- [PAT 创建指南](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

---

**最后更新**: 2026-03-01
**维护者**: @tigerbreak
