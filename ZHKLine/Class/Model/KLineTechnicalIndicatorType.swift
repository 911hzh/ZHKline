enum KLineTechnicalIndicatorType {
    case ma        // 移动平均线
    case ema       // 指数移动平均线
    case boll      // 布林带
    
    case macd      // MACD
    case kdj       // KDJ
    case rsi       // RSI
    case wr        // 威廉指标
    case volume    // 成交量
    
    /// 主图技术指标类型
    static let mainTypes: [KLineTechnicalIndicatorType] = [.ma, .ema, .boll]
    
    /// 副图技术指标类型
    static let secondTypes: [KLineTechnicalIndicatorType] = [.volume, .macd, .kdj, .rsi, .wr]
}
