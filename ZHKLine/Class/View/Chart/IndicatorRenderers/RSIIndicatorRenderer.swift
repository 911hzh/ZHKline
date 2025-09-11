//
//  RSIIndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// RSI指标绘制器
class RSIIndicatorRenderer: BaseIndicatorRenderer {
    
    override func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        // 创建RSI专用layer
        let rsiLayer = KLineBaseLayer()
        rsiLayer.frame = frame
        
        // 获取RSI数据的实际范围
        let rsi6Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.rsi6 }
        let rsi12Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.rsi12 }
        let rsi24Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.rsi24 }
        
        let allValues = rsi6Values + rsi12Values + rsi24Values
        guard !allValues.isEmpty else { return rsiLayer }
        
        let minValue = allValues.min() ?? 0
        let maxValue = allValues.max() ?? 0
        
        // 确保有一定的范围，避免minValue == maxValue
        let range = maxValue - minValue
        let adjustedMin = range > 0 ? minValue : minValue - 5
        let adjustedMax = range > 0 ? maxValue : maxValue + 5
        
        let valueRange = (min: adjustedMin, max: adjustedMax)
        
        // 在RSI layer内绘制（使用layer内部坐标系）
        drawRSILines(on: rsiLayer, layerSize: frame.size, valueRange: valueRange, klineModels: klineModels, positionModels: positionModels)
        
        return rsiLayer
    }
    
    override func createIndicatorValueLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel], selectedKLineModel: KLineModel?) -> [CALayer] {
        // 只有选中K线数据时才显示指标数值
        guard let selectedModel = selectedKLineModel,
              let indicators = selectedModel.KLineTechnicalIndicatorsModel else {
            return [] // 没有选中数据时不显示任何数值标签
        }
        
        let xOffset: CGFloat = 10
        let yPosition: CGFloat = frame.minY + 5
        let labelHeight: CGFloat = 13
        let spacing: CGFloat = 3
        
        return createSecondaryIndicatorLabels(
            xOffset: xOffset,
            yPosition: yPosition,
            labelHeight: labelHeight,
            spacing: spacing,
            title: "RSI:",
            titleColor: KLineConfig.shared.rsi6Color,
            values: [
                ("6", indicators.rsi6, KLineConfig.shared.rsi6Color),
                ("12", indicators.rsi12, KLineConfig.shared.rsi12Color),
                ("24", indicators.rsi24, KLineConfig.shared.rsi24Color)
            ]
        )
    }
    
    // MARK: - 私有绘制方法
    
    /// 在指定layer上绘制RSI线
    private func drawRSILines(on layer: KLineBaseLayer, layerSize: CGSize, valueRange: (min: Double, max: Double), klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 计算各线的位置点
        let rsi6Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.rsi6 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let rsi12Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.rsi12 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let rsi24Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.rsi24 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        drawLineChart(
            on: layer,
            layerSize: layerSize,
            points: [
                (rsi6Points, KLineConfig.shared.rsi6Color, "RSI6"),
                (rsi12Points, KLineConfig.shared.rsi12Color, "RSI12"),
                (rsi24Points, KLineConfig.shared.rsi24Color, "RSI24")
            ]
        )
    }
}
