# ZHKLine CI/CD 设置说明

## 🎯 完成的配置

✅ **GitHub Actions CI/CD 流程**

- 自动构建和测试
- 代码质量检查 (SwiftLint)
- 代码覆盖率检查
- 多平台支持 (iOS Simulator)

✅ **分支保护规则配置**

- master/main 和 develop 分支保护
- 强制 Pull Request 审查
- CI 检查必须通过

✅ **代码质量工具**

- SwiftLint 配置和规则
- Git 预提交钩子
- 自动化代码检查

✅ **项目模板**

- Pull Request 模板
- Issue 模板 (Bug 报告和功能请求)
- 代码审查清单

## 📋 需要手动完成的设置

### 1. 在 GitHub 上配置分支保护规则

#### 对于 master/main 分支：

1. 进入 GitHub 仓库
2. 点击 Settings → Branches → Add rule
3. Branch name pattern: `master` (或 `main`)
4. 勾选以下选项：
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1
     - ✅ Dismiss stale PR approvals when new commits are pushed
     - ✅ Require review from code owners
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - 添加必需状态检查：
       - `build-and-test`
       - `swiftlint`
   - ✅ Require conversation resolution before merging
   - ✅ Include administrators
   - ❌ Allow force pushes (关闭)
   - ❌ Allow deletions (关闭)

#### 对于 develop 分支：

重复上述步骤，Branch name pattern 设为 `develop`，但不需要 "Require review from code owners"

### 2. 配置 GitHub Actions Secrets（如果需要）

如果您的项目需要特殊的密钥或证书：

1. 进入 GitHub 仓库
2. 点击 Settings → Secrets and variables → Actions
3. 添加必要的 secrets

### 3. 设置 Code Owners（可选但推荐）

`.github/CODEOWNERS` 文件已创建，但需要更新 GitHub 用户名：

```bash
# 编辑 .github/CODEOWNERS 文件
# 将 @huang 替换为实际的 GitHub 用户名
```

## 🚀 开始使用

### 1. 安装开发工具

```bash
# 安装 Git hooks
./scripts/install-hooks.sh

# 验证 SwiftLint
swiftlint version
```

### 2. 测试 CI/CD

```bash
# 创建测试分支
git checkout -b test/ci-setup

# 进行小修改测试
echo "# Test CI" >> test.md
git add test.md
git commit -m "test: CI/CD 配置测试"
git push origin test/ci-setup

# 在 GitHub 创建 Pull Request 观察 CI 运行
```

### 3. 验证分支保护

尝试直接推送到 develop 分支应该被阻止：

```bash
git checkout develop
echo "# Direct push test" >> test2.md
git add test2.md
git commit -m "test: 直接推送测试"
git push origin develop  # 这应该被 pre-push hook 阻止
```

## 📝 工作流程

### 开发新功能

```bash
# 1. 从 develop 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/新功能名称

# 2. 开发代码
# 编辑文件...

# 3. 提交（会自动进行代码质量检查）
git add .
git commit -m "feat(组件): 添加新功能描述"

# 4. 推送并创建 PR
git push origin feature/新功能名称
# 在 GitHub 创建 Pull Request
```

### 发布流程

```bash
# 1. 创建发布分支
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. 更新版本信息
# 编辑版本文件...

# 3. 创建 PR 到 master
git push origin release/v1.0.0
# 创建 PR: release/v1.0.0 → master

# 4. 合并后创建标签
git checkout master
git pull origin master
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 🛠️ 故障排除

### SwiftLint 错误

```bash
# 查看详细错误
swiftlint lint --reporter json

# 自动修复部分问题
swiftlint --fix
```

### Git Hooks 问题

```bash
# 重新安装 hooks
./scripts/install-hooks.sh

# 跳过 hooks（紧急情况）
git commit --no-verify
```

### CI 失败

1. 检查 GitHub Actions 日志
2. 本地复现 CI 环境：
   ```bash
   xcodebuild clean build test \
     -project ZHKLine.xcodeproj \
     -scheme ZHKLine \
     -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

## 📊 监控和维护

### 代码质量监控

- 定期检查 SwiftLint 报告
- 监控测试覆盖率
- 审查 CI/CD 性能

### 规则更新

- 根据团队反馈调整 SwiftLint 规则
- 更新 CI/CD 配置以适应新需求
- 定期更新依赖和工具版本

## 📚 相关文档

- [CI/CD 详细配置](docs/CI_CD_SETUP.md)
- [分支保护设置](.github/BRANCH_PROTECTION.md)
- [贡献指南](CONTRIBUTING.md)
- [项目架构](PROJECT_ARCHITECTURE.md)

---

**注意**：确保所有团队成员都熟悉这些流程，并在开始开发前完成相应的设置。
