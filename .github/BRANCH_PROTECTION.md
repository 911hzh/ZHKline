# 分支保护规则配置指南

## 🛡️ 分支保护设置

为了确保代码质量和防止意外合并，需要在 GitHub 仓库设置中配置以下分支保护规则：

### Master/Main 分支保护

在 GitHub 仓库 → Settings → Branches → Add rule 中添加：

1. **Branch name pattern**: `master` 或 `main`
2. **保护设置**:
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1
     - ✅ Dismiss stale PR approvals when new commits are pushed
     - ✅ Require review from code owners
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - 必需状态检查：
       - `build-and-test`
       - `swiftlint`
   - ✅ Require conversation resolution before merging
   - ✅ Require signed commits
   - ✅ Require linear history
   - ✅ Include administrators
   - ✅ Allow force pushes: ❌ (禁用)
   - ✅ Allow deletions: ❌ (禁用)

### Develop 分支保护

在 GitHub 仓库 → Settings → Branches → Add rule 中添加：

1. **Branch name pattern**: `develop`
2. **保护设置**:
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1
     - ✅ Dismiss stale PR approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - 必需状态检查：
       - `build-and-test`
       - `swiftlint`
   - ✅ Require conversation resolution before merging
   - ✅ Include administrators
   - ✅ Allow force pushes: ❌ (禁用)
   - ✅ Allow deletions: ❌ (禁用)

## 👥 Code Owners 设置

创建 `.github/CODEOWNERS` 文件以指定代码审查者：

```
# 全局代码审查者
* @huang

# Swift文件特定审查者
*.swift @huang

# 配置文件审查者
*.yml @huang
*.yaml @huang
*.json @huang

# 项目配置文件
*.xcodeproj/* @huang
Package.swift @huang
```

## 🔄 工作流程

### 功能开发流程

1. 从 `develop` 分支创建功能分支: `feature/功能名称`
2. 在功能分支上开发
3. 提交代码并推送到远程仓库
4. 创建 Pull Request 到 `develop` 分支
5. CI/CD 自动运行测试和代码质量检查
6. 等待代码审查和批准
7. 合并到 `develop` 分支

### 发布流程

1. 从 `develop` 分支创建发布分支: `release/版本号`
2. 在发布分支上进行最后的调整和测试
3. 创建 Pull Request 到 `master` 分支
4. 通过审查后合并到 `master`
5. 在 `master` 分支创建版本标签
6. 将 `master` 分支的变更合并回 `develop`

### 热修复流程

1. 从 `master` 分支创建热修复分支: `hotfix/问题描述`
2. 修复问题
3. 创建 Pull Request 到 `master` 分支
4. 快速审查和合并
5. 将变更合并回 `develop` 分支

## 📋 代码审查清单

### 审查者需要检查的项目：

- [ ] 代码逻辑正确性
- [ ] 性能考虑
- [ ] 内存管理
- [ ] 错误处理
- [ ] UI 适配
- [ ] 测试覆盖
- [ ] 文档更新
- [ ] 安全性考虑
- [ ] 代码风格一致性
- [ ] 最佳实践遵循

## 🚨 紧急情况处理

在紧急情况下，如果需要绕过某些保护规则：

1. 需要管理员权限
2. 必须记录绕过原因
3. 事后必须补充完整的测试和审查
4. 在下一个工作日内创建 Issue 跟踪

## 📞 联系方式

如有疑问，请联系：

- 主要审查者：@huang
- 项目维护者：@huang
