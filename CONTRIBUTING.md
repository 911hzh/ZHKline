# 贡献指南

欢迎为 ZHKLine 项目做出贡献！这个文档将指导您如何参与项目开发。

## 🌟 如何贡献

### 报告 Bug

使用 GitHub Issues 报告 bug 时，请：

1. 使用 Bug 报告模板
2. 提供详细的复现步骤
3. 包含环境信息和截图
4. 添加相应的标签

### 建议新功能

1. 先检查是否已有类似的 Issue 或 PR
2. 使用功能请求模板创建 Issue
3. 详细描述功能需求和使用场景
4. 等待讨论和确认后再开始开发

### 提交代码

1. Fork 项目到您的 GitHub 账户
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: 添加某某功能'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📋 开发环境配置

### 必需工具

- Xcode 15.0+
- iOS 13.0+ SDK
- SwiftLint
- Git

### 安装步骤

```bash
# 克隆项目
git clone https://github.com/your-username/ZHKline.git
cd ZHKline

# 安装Git hooks
./scripts/install-hooks.sh

# 打开项目
open ZHKLine.xcodeproj
```

## 📝 代码规范

### Swift 代码风格

我们使用 SwiftLint 来保证代码风格一致性。主要规则包括：

1. **命名规范**

   - 类名和协议名使用 PascalCase
   - 变量和函数名使用 camelCase
   - 常量使用 camelCase 或 PascalCase

   ```swift
   class KLineChartView: UIView {
       let maxDataPoints = 1000
       var currentPrice: Double = 0.0

       func updateChartData() {
           // 实现
       }
   }
   ```

2. **代码组织**

   - 使用 MARK 注释分组代码
   - 按功能逻辑组织方法

   ```swift
   class KLineView: UIView {
       // MARK: - Properties
       private var chartView: KLineChartView!

       // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
       }

       // MARK: - Private Methods
       private func setupUI() {
           // 实现
       }
   }
   ```

3. **注释规范**
   - 公开 API 必须有文档注释
   - 复杂逻辑添加行内注释
   ```swift
   /// 计算K线技术指标
   /// - Parameters:
   ///   - data: 原始K线数据
   ///   - type: 指标类型
   /// - Returns: 计算后的指标数据
   func calculateIndicator(data: [KLineModel], type: IndicatorType) -> [Double] {
       // 具体实现
   }
   ```

### 文件组织

```
ZHKLine/Class/
├── Base/           # 基础类和工具
├── Model/          # 数据模型
├── View/           # 视图组件
├── Util/           # 工具类
└── Extensions/     # 扩展
```

## 🧪 测试规范

### 单元测试

- 为新功能编写单元测试
- 测试覆盖率应保持在 80%以上
- 使用描述性的测试方法名

```swift
func testKLineDataCalculation_withValidData_shouldReturnCorrectResults() {
    // Given
    let testData = createTestKLineData()

    // When
    let result = calculator.calculate(testData)

    // Then
    XCTAssertEqual(result.count, testData.count)
    XCTAssertTrue(result.first!.isValid)
}
```

### UI 测试

- 为关键用户流程编写 UI 测试
- 测试不同屏幕尺寸的适配
- 测试暗黑模式和浅色模式

## 🔄 提交规范

### 提交消息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型(type)**:

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式化
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**范围(scope)** (可选):

- `chart`: 图表相关
- `api`: API 相关
- `model`: 数据模型
- `ui`: 用户界面

**示例**:

```
feat(chart): 添加MACD指标显示

- 实现MACD指标计算逻辑
- 添加MACD指标渲染器
- 更新图表配置选项

Closes #123
```

## 🎯 Pull Request 规范

### PR 标题

使用与提交消息相同的格式：

```
feat(chart): 添加RSI指标支持
```

### PR 描述

使用提供的 PR 模板，确保包含：

- 变更描述
- 测试说明
- 截图(如适用)
- 相关 Issue 链接

### 代码审查

- 至少需要一个审查者批准
- 所有 CI 检查必须通过
- 解决所有审查意见

## 📖 文档规范

### README 更新

重要功能更改时需要更新 README 文档

### API 文档

- 公开 API 需要详细的文档注释
- 包含使用示例
- 说明参数和返回值

### 架构文档

重大架构变更需要更新 PROJECT_ARCHITECTURE.md

## 🚀 发布流程

### 版本号规范

我们使用语义化版本控制(SemVer)：

- `MAJOR.MINOR.PATCH`
- `1.0.0` → `1.0.1` (补丁)
- `1.0.0` → `1.1.0` (次要版本)
- `1.0.0` → `2.0.0` (主要版本)

### 发布步骤

1. 从 develop 创建 release 分支
2. 更新版本号和 CHANGELOG
3. 创建 PR 到 master 分支
4. 审查和合并
5. 创建 GitHub Release 和 Tag

## 💡 最佳实践

### 性能考虑

- 避免在主线程进行繁重计算
- 使用适当的数据结构
- 合理使用缓存
- 注意内存泄漏

### 安全考虑

- 验证输入数据
- 避免硬编码敏感信息
- 使用安全的网络通信

### 用户体验

- 提供加载状态指示
- 优雅的错误处理
- 支持不同屏幕尺寸
- 考虑可访问性

## 🆘 获取帮助

### 联系方式

- 创建 GitHub Issue
- 在 PR 中@提及维护者
- 查看现有文档和代码

### 有用资源

- [iOS 开发指南](https://developer.apple.com/ios/)
- [Swift 编程语言](https://swift.org/documentation/)
- [SwiftLint 规则](https://realm.github.io/SwiftLint/rule-directory.html)

## 🙏 致谢

感谢所有为项目做出贡献的开发者！

---

如有任何问题，请随时创建 Issue 或联系项目维护者。
