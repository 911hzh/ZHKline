//
//  IndicatorRendererFactory.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// 指标绘制器工厂类
class IndicatorRendererFactory {
    
    /// 根据指标类型创建对应的绘制器
    /// - Parameter indicatorType: 指标类型
    /// - Returns: 指标绘制器实例
    static func createRenderer(for indicatorType: KLineTechnicalIndicatorType) -> IndicatorRenderer? {
        switch indicatorType {
        case .volume:
            return VolumeIndicatorRenderer()
        case .macd:
            return MACDIndicatorRenderer()
        case .kdj:
            return KDJIndicatorRenderer()
        case .rsi:
            return RSIIndicatorRenderer()
        case .wr:
            return WRIndicatorRenderer()
        default:
            return nil // 主图指标不在这里处理
        }
    }
}
