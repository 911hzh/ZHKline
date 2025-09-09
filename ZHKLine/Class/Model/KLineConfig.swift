//
//  ZHKLineStyle.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import UIKit

// 属性包装器：自动处理需要缩放的属性
@propertyWrapper
public struct ScaleValue {
    private var baseValue: CGFloat
    private let scalePointer: UnsafePointer<CGFloat>
    
    public init(wrappedValue: CGFloat, scalePointer: UnsafePointer<CGFloat>) {
        self.baseValue = wrappedValue
        self.scalePointer = scalePointer
    }
    
    public var wrappedValue: CGFloat {
        get {
            return baseValue * scalePointer.pointee
        }
        set {
            baseValue = newValue
        }
    }
    
    // 获取原始基础值（不带缩放）
    public var baseValue_: CGFloat {
        return baseValue
    }
}
public class KLineConfig {
    static let shared = KLineConfig()
    
    // 缩放因子（静态变量，所有实例共享）
    public static var scale: CGFloat = 1.0
    
    // 使用属性包装器的可缩放属性
    @ScaleValue(wrappedValue: 8.5, scalePointer: &KLineConfig.scale) public var candleWidth: CGFloat
    @ScaleValue(wrappedValue: 2, scalePointer: &KLineConfig.scale) public var candleSpace: CGFloat
    public var crossLineWidth: CGFloat = 1
    
    // 不需要缩放的属性
    public let candleMidleLineWidth: CGFloat
    public let crossLineColor: UIColor
    public let crossHorCount: Int
    public let crossVerticalCount: Int
    public let crossTopHeight: CGFloat
    public let crossItemHeight: CGFloat
    
    // 蜡烛颜色配置
    public let candleUpColor: UIColor       // 上涨蜡烛颜色（阳线）
    public let candleDownColor: UIColor     // 下跌蜡烛颜色（阴线）
    public let candleWickColor: UIColor     // 影线颜色
    
    // 技术指标配置
    public let indicatorLineWidth: CGFloat  // 技术指标线条宽度
    public let volumeBarWidthRatio: CGFloat // 成交量柱状图宽度比例（相对于蜡烛宽度）
    public let macdBarWidthRatio: CGFloat   // MACD柱状图宽度比例（相对于蜡烛宽度）
    
    public let chartViewPadding: UIEdgeInsets
    
    // 主图技术指标颜色配置
    public let ma5Color: UIColor        // MA5线颜色
    public let ma10Color: UIColor       // MA10线颜色
    public let ma30Color: UIColor       // MA30线颜色
    
    public let ema5Color: UIColor       // EMA5线颜色
    public let ema10Color: UIColor      // EMA10线颜色
    public let ema30Color: UIColor      // EMA30线颜色
    
    public let bollUpperColor: UIColor  // BOLL上轨颜色
    public let bollMiddleColor: UIColor // BOLL中轨颜色
    public let bollLowerColor: UIColor  // BOLL下轨颜色
    
    // 副图技术指标颜色配置
    // MACD颜色
    public let macdDifColor: UIColor    // MACD DIF线颜色
    public let macdDeaColor: UIColor    // MACD DEA线颜色
    
    // KDJ颜色
    public let kdjKColor: UIColor       // KDJ K线颜色
    public let kdjDColor: UIColor       // KDJ D线颜色
    public let kdjJColor: UIColor       // KDJ J线颜色
    
    // RSI颜色
    public let rsi6Color: UIColor       // RSI6线颜色
    public let rsi12Color: UIColor      // RSI12线颜色
    public let rsi24Color: UIColor      // RSI24线颜色
    
    // WR颜色
    public let wr6Color: UIColor        // WR6线颜色
    public let wr10Color: UIColor       // WR10线颜色
    public let wr14Color: UIColor       // WR14线颜色
    
    // VOL颜色
    public let volumeMA5Color: UIColor  // 成交量MA5线颜色
    public let volumeMA10Color: UIColor // 成交量MA10线颜色
    
    // 技术指标文字颜色配置
    public let indicatorTextColor: UIColor      // 指标文字颜色
    public let indicatorTextBackgroundColor: UIColor // 指标文字背景颜色
    
    public let indicatorTypeControlHeight: CGFloat
    
    /**
     蜡烛图的边距
     */
    public let crandleInsets: UIEdgeInsets = UIEdgeInsets(top: 30, left: 2, bottom: 30, right: 2)
    init(
        candleMidleLineWidth: CGFloat = 1,
        crossLineColor: UIColor = UIColor(hexString: "#DFDFDF"),
        crossHorCount: Int = 5,
        crossTopHeight: CGFloat = 30,
        crossVerticalCount: Int = 6,
        crossItemHeight: CGFloat = 70,
        indicatorTypeControlHeight: CGFloat = 40,
        candleUpColor: UIColor = UIColor(hexString: "#F14965"),
        candleDownColor: UIColor = UIColor(hexString: "#00B066"),
        candleWickColor: UIColor = UIColor(hexString: "#666666"),
        chartViewPadding: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 2),
        indicatorLineWidth: CGFloat = 1.0,
        volumeBarWidthRatio: CGFloat = 1.0,
        macdBarWidthRatio: CGFloat = 0.6,
        // 主图技术指标颜色
        ma5Color: UIColor = UIColor(hexString: "#FFD700"),    // 金色
        ma10Color: UIColor = UIColor(hexString: "#00BFFF"),   // 深天蓝
        ma30Color: UIColor = UIColor(hexString: "#DA70D6"),   // 兰花紫
        ema5Color: UIColor = UIColor(hexString: "#FF8C00"),   // 深橙色
        ema10Color: UIColor = UIColor(hexString: "#32CD32"),  // 酸橙绿
        ema30Color: UIColor = UIColor(hexString: "#9966CC"),  // 紫罗兰
        bollUpperColor: UIColor = UIColor(hexString: "#FF6666"), // 浅红色
        bollMiddleColor: UIColor = UIColor(hexString: "#66CC66"), // 浅绿色
        bollLowerColor: UIColor = UIColor(hexString: "#6666FF"), // 浅蓝色
        // 副图技术指标颜色
        macdDifColor: UIColor = UIColor(hexString: "#00BFFF"),   // 深天蓝
        macdDeaColor: UIColor = UIColor(hexString: "#FF8C00"),   // 深橙色
        kdjKColor: UIColor = UIColor(hexString: "#00BFFF"),      // 深天蓝
        kdjDColor: UIColor = UIColor(hexString: "#FF8C00"),      // 深橙色
        kdjJColor: UIColor = UIColor(hexString: "#DA70D6"),      // 兰花紫
        rsi6Color: UIColor = UIColor(hexString: "#FF4500"),      // 橙红色
        rsi12Color: UIColor = UIColor(hexString: "#32CD32"),     // 酸橙绿
        rsi24Color: UIColor = UIColor(hexString: "#00BFFF"),     // 深天蓝
        wr6Color: UIColor = UIColor(hexString: "#FF4500"),       // 橙红色
        wr10Color: UIColor = UIColor(hexString: "#32CD32"),      // 酸橙绿
        wr14Color: UIColor = UIColor(hexString: "#00BFFF"),      // 深天蓝
        volumeMA5Color: UIColor = UIColor(hexString: "#00BFFF"), // 深天蓝
        volumeMA10Color: UIColor = UIColor(hexString: "#FF8C00"), // 深橙色
        // 技术指标文字颜色
        indicatorTextColor: UIColor = UIColor(hexString: "#666666"),
        indicatorTextBackgroundColor: UIColor = UIColor(hexString: "#F5F5F5")
    ) {
        // 初始化不需要缩放的属性
        self.candleMidleLineWidth = candleMidleLineWidth
        self.crossLineColor = crossLineColor
        self.crossHorCount = crossHorCount
        self.crossVerticalCount = crossVerticalCount
        self.crossTopHeight = crossTopHeight
        self.crossItemHeight = crossItemHeight
        self.candleUpColor = candleUpColor
        self.candleDownColor = candleDownColor
        self.candleWickColor = candleWickColor
        self.indicatorLineWidth = indicatorLineWidth
        self.volumeBarWidthRatio = volumeBarWidthRatio
        self.macdBarWidthRatio = macdBarWidthRatio
        self.indicatorTypeControlHeight = indicatorTypeControlHeight
        
        // 初始化主图技术指标颜色
        self.ma5Color = ma5Color
        self.ma10Color = ma10Color
        self.ma30Color = ma30Color
        self.ema5Color = ema5Color
        self.ema10Color = ema10Color
        self.ema30Color = ema30Color
        self.bollUpperColor = bollUpperColor
        self.bollMiddleColor = bollMiddleColor
        self.bollLowerColor = bollLowerColor
        
        // 初始化副图技术指标颜色
        self.macdDifColor = macdDifColor
        self.macdDeaColor = macdDeaColor
        self.kdjKColor = kdjKColor
        self.kdjDColor = kdjDColor
        self.kdjJColor = kdjJColor
        self.rsi6Color = rsi6Color
        self.rsi12Color = rsi12Color
        self.rsi24Color = rsi24Color
        self.wr6Color = wr6Color
        self.wr10Color = wr10Color
        self.wr14Color = wr14Color
        self.volumeMA5Color = volumeMA5Color
        self.volumeMA10Color = volumeMA10Color
        
        // 初始化技术指标文字颜色
        self.indicatorTextColor = indicatorTextColor
        self.indicatorTextBackgroundColor = indicatorTextBackgroundColor
        self.chartViewPadding = chartViewPadding
        
    }
    /**
     获取整个KLineView的高度
     */
    func getAllHeight(indicatorTypes: [KLineTechnicalIndicatorType]) -> CGFloat {
        let seconedHeight = getSecoendHeight(indicatorTypes: indicatorTypes)
        return mainCanvasHeight + seconedHeight + indicatorTypeControlHeight
    }
    /**
     获取幅图的高度
     */
    func getSecoendHeight(indicatorTypes: [KLineTechnicalIndicatorType]) -> CGFloat {
        let needSeconed: [KLineTechnicalIndicatorType] = [.macd, .kdj, .rsi, .wr, .volume]
        let seconedTypes = indicatorTypes.filter({needSeconed.contains($0)})
        let seconedHeight = crossItemHeight * CGFloat(seconedTypes.count)
        return seconedHeight
    }
    /**
     获取indicatorView的Y坐标
     */
    func getIndicatorControlMinY(indicatorTypes: [KLineTechnicalIndicatorType]) -> CGFloat {
        return getAllHeight(indicatorTypes: indicatorTypes) - indicatorTypeControlHeight
    }
    /**
     获取主图的高度
     */
    var mainCanvasHeight: CGFloat {
        return CGFloat(crossHorCount - 1) * crossItemHeight + crandleInsets.bottom + crandleInsets.top + KLineConfig.shared.chartViewPadding.bottom + KLineConfig.shared.chartViewPadding.left
    }
    
}
