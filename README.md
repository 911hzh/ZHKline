# ZHKLine

![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

一个高性能、功能完整的 Swift K线图表库，专为iOS金融应用设计。采用先进的架构设计，支持多种技术指标，提供流畅的用户交互体验。

## ✨ 特性

### 📊 完整的技术指标支持
- **缩放位置精准**: 放大缩小是两个手指中间位置开始缩放
- **滑动非常顺滑，基于UIScrollView的滑动实现，惯性滚动, 减速等不再生硬**
- **高度自定义机制**： 各个组件使用纯函数的编码方式，用户快速拼接各个模块生成自己的的UI
- **高扩展性**: 可以轻松的扩展新的技术指标，使用策略模式添加
- **主图指标**: MA(5,10,30)、EMA(5,10,30)、BOLL(布林带)
- **副图指标**: MACD、KDJ、RSI(6,12,24)、WR(6,10,14)、VOL(成交量)
- **实时计算**: 所有技术指标实时计算，无延迟显示
- **多选支持**: 支持同时显示多个技术指标

 



### 🚀 卓越性能
- **性能优异**: 使用CAShapeLayer绘制，计算与渲染分离
- **预计算优化**: 一次计算，多次复用
- **流畅交互**: 60FPS 平滑滚动和缩放
- **内存友好**: 智能内存管理，支持大数据量

### 🎨 精美界面
- **火币风格**: 高度还原火币交易界面
- **十字线功能**: 精确的价格和时间显示
- **详情面板**: 实时显示K线详细信息
- **手势交互**: 支持缩放、拖拽、长按选择

### 🛠 开发者友好
- **Swift 原生**: 100% Swift 实现，无第三方依赖
- **模块化设计**: 清晰的代码结构，易于扩展
- **使用纯函数编码**: 代码更简洁，更易于维护，用户可以快速的测试某一个组件的绘制，单独拿出来使用
- **丰富文档**: 详细的使用说明和架构文档
- **单元测试**: 完整的测试覆盖

## 📱 效果预览

<table>
<tr>
<td width="50%">

**K线图表**
- 蜡烛图显示
- 技术指标叠加
- 十字线交互

</td>
<td width="50%">

**技术指标**
- 多种指标选择
- 实时数值显示
- 流畅切换动画

</td>
</tr>
</table>

## 🚀 快速开始

### 安装

#### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ZHKLine.git", from: "1.0.0")
]
```

#### CocoaPods
```ruby
pod 'ZHKLine'
```

### 基础用法

```swift
import ZHKLine

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 创建K线视图
        let klineView = ZHKLineView(frame: view.bounds)
        view.addSubview(klineView)
        
        // 2. 设置数据
        let klineData = DataUtil.toKLineModelsWithIndicators(datas: yourRawData)
        klineView.setupDatas(datas: klineData)
        
        // 3. 监听高度变化（可选）
        klineView.heightChanged = { height in
            // 处理视图高度变化
        }
    }
}
```

### 自定义配置

```swift
// 自定义颜色和样式
ZHKLineConfig.shared.candleUpColor = UIColor.green
ZHKLineConfig.shared.candleDownColor = UIColor.red
ZHKLineConfig.shared.candleWidth = 8.0

// 缩放功能
ZHKLineConfig.scale = 1.2  // 放大1.2倍
klineView.setupDatas(datas: klineData)  // 重新绘制
```

## 📖 详细文档

### 核心组件

#### ZHKLineView
主要的K线图表视图，提供完整的K线图表功能。

```swift
let klineView = ZHKLineView(frame: CGRect)
klineView.setupDatas(datas: [KLineModel])
klineView.heightChanged = { height in /* 处理高度变化 */ }
```

#### KLineModel
K线数据模型，包含OHLCV数据和技术指标。

```swift
struct KLineModel {
    let klineData: KLineData                    // 原始K线数据
    var KLineTechnicalIndicatorsModel: KLineTechnicalIndicatorsModel?  // 技术指标数据
    
    // 便捷访问属性
    var open: Double { }
    var close: Double { }
    var high: Double { }
    var low: Double { }
    var volume: Double { }
}
```

#### DataUtil
技术指标计算工具类，提供所有技术指标的计算方法。

```swift
// 自动计算所有技术指标
let modelsWithIndicators = DataUtil.toKLineModelsWithIndicators(datas: rawData)

// 单独计算指标
let ma5 = DataUtil.calculateMA(prices: closePrices, period: 5)
let macd = DataUtil.calculateMACD(prices: closePrices)
let kdj = DataUtil.calculateKDJ(klineData: klineData)
```

### 技术指标说明

| 指标 | 说明 | 参数 |
|------|------|------|
| MA | 简单移动平均线 | 周期: 5, 10, 30 |
| EMA | 指数移动平均线 | 周期: 5, 10, 30 |
| BOLL | 布林带 | 周期: 20, 倍数: 2 |
| MACD | 指数平滑移动平均线 | 快线: 12, 慢线: 26, 信号线: 9 |
| KDJ | 随机指标 | 周期: 9, K平滑: 3, D平滑: 3 |
| RSI | 相对强弱指标 | 周期: 6, 12, 24 |
| WR | 威廉指标 | 周期: 6, 10, 14 |
| VOL | 成交量 | MA周期: 5, 10 |

## 🏗 架构设计

ZHKLine 采用先进的架构设计，确保高性能和可维护性：

### 核心设计原则
1. **纯函数设计**: 计算逻辑无副作用，易于测试
2. **职责分离**: 数据计算、位置计算、视图渲染完全分离
3. **预计算优化**: 所有位置信息预先计算，避免重复计算

### 关键组件
- **DataUtil**: 技术指标计算引擎
- **KLineCrandleIndexUtil**: 位置计算工具
- **IndicatorRenderer**: 指标渲染器工厂
- **KLineScaleGestureManager**: 手势交互管理

### 数据流
```
原始数据 → 技术指标计算 → 位置计算 → 渲染绘制 → 用户交互
```

## 🤝 贡献

我们欢迎所有形式的贡献！

### 如何贡献
1. Fork 这个项目
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建一个 Pull Request

### 贡献指南
- 遵循现有的代码风格
- 添加必要的测试用例
- 更新相关文档
- 确保所有测试通过

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙋‍♂️ 支持

如果您遇到问题或有建议，请：

1. 查看 [Issues](https://github.com/yourusername/ZHKLine/issues) 页面
2. 创建新的 Issue 描述问题
3. 或者发送邮件至 your.email@example.com

## 🚀 路线图

- [ ] 分时图支持
- [ ] SwiftUI 支持
- [ ] 更多技术指标 (CCI, OBV等)
- [ ] 主题系统
- [ ] WebSocket 实时数据支持
- [ ] 画线工具

## ⭐ Star History

如果这个项目对您有帮助，请给我们一个 Star！

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/ZHKLine&type=Date)](https://star-history.com/#yourusername/ZHKLine&Date)

---

**由  和 Swift 制作**
