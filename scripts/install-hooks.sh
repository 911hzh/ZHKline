#!/bin/bash

# Git hooks installation script for ZHKLine project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

print_info "Installing Git hooks for ZHKLine project..."

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    print_error "Not in a Git repository! Please run this script from the project root."
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
print_info "Installing pre-commit hook..."
cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
print_success "Pre-commit hook installed"

# Create a simple commit message hook
print_info "Creating commit-msg hook..."
cat > "$HOOKS_DIR/commit-msg" << 'EOF'
#!/bin/bash

# Commit message hook for ZHKLine project

commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,50}'

error_msg="Commit message格式错误! 
格式应为: <type>(<scope>): <subject>

允许的类型:
- feat: 新功能
- fix: Bug修复  
- docs: 文档更新
- style: 代码格式化
- refactor: 代码重构
- test: 测试相关
- chore: 构建/工具相关
- perf: 性能优化
- ci: CI配置
- build: 构建系统
- revert: 回滚

示例: 
- feat(chart): 添加新的K线指标
- fix(api): 修复数据请求错误
- docs: 更新README文档"

if ! grep -qE "$commit_regex" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi
EOF

chmod +x "$HOOKS_DIR/commit-msg"
print_success "Commit-msg hook installed"

# Create pre-push hook
print_info "Creating pre-push hook..."
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash

# Pre-push hook for ZHKLine project

protected_branch='(master|main|develop)'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ "$current_branch" =~ $protected_branch ]]; then
    echo "❌ 直接推送到保护分支 ($current_branch) 被禁止!"
    echo "请使用Pull Request流程:"
    echo "1. 创建feature分支"
    echo "2. 推送到feature分支" 
    echo "3. 创建Pull Request"
    exit 1
fi

echo "✅ 推送到分支: $current_branch"
EOF

chmod +x "$HOOKS_DIR/pre-push"
print_success "Pre-push hook installed"

print_success "所有Git hooks安装完成! 🎉"
print_info "现在您的提交将自动进行代码质量检查。"

# Test if SwiftLint is available
if ! command -v swiftlint &> /dev/null; then
    print_info "SwiftLint未安装。正在安装..."
    if command -v brew &> /dev/null; then
        brew install swiftlint
        print_success "SwiftLint安装完成"
    else
        print_error "请手动安装SwiftLint: brew install swiftlint"
    fi
fi

echo ""
print_info "使用说明:"
echo "• 每次提交时会自动运行代码质量检查"
echo "• 提交消息必须遵循约定格式"
echo "• 禁止直接推送到master/main/develop分支"
echo "• 如需跳过检查，使用: git commit --no-verify"
