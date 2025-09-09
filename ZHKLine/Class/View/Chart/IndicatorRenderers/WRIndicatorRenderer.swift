//
//  WRIndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// WR指标绘制器
class WRIndicatorRenderer: BaseIndicatorRenderer {
    
    override func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        // 创建WR专用layer
        let wrLayer = KLineBaseLayer()
        wrLayer.frame = frame
        
        // 获取WR数据的实际范围
        let wr6Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.wr6 }
        let wr10Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.wr10 }
        let wr14Values = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.wr14 }
        
        let allValues = wr6Values + wr10Values + wr14Values
        guard !allValues.isEmpty else { return wrLayer }
        
        let minValue = allValues.min()!
        let maxValue = allValues.max()!
        
        // 确保有一定的范围，避免minValue == maxValue
        let range = maxValue - minValue
        let adjustedMin = range > 0 ? minValue : minValue - 5
        let adjustedMax = range > 0 ? maxValue : maxValue + 5
        
        let valueRange = (min: adjustedMin, max: adjustedMax)
        
        // 在WR layer内绘制（使用layer内部坐标系）
        drawWRLines(on: wrLayer, layerSize: frame.size, valueRange: valueRange, klineModels: klineModels, positionModels: positionModels)
        
        return wrLayer
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
            title: "WR:",
            titleColor: KLineConfig.shared.wr6Color,
            values: [
                ("6", indicators.wr6, KLineConfig.shared.wr6Color),
                ("10", indicators.wr10, KLineConfig.shared.wr10Color),
                ("14", indicators.wr14, KLineConfig.shared.wr14Color)
            ]
        )
    }
    
    // MARK: - 私有绘制方法
    
    /// 在指定layer上绘制WR线
    private func drawWRLines(on layer: KLineBaseLayer, layerSize: CGSize, valueRange: (min: Double, max: Double), klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 计算各线的位置点
        let wr6Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.wr6 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let wr10Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.wr10 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let wr14Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.wr14 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        drawLineChart(
            on: layer,
            layerSize: layerSize,
            points: [
                (wr6Points, KLineConfig.shared.wr6Color, "WR6"),
                (wr10Points, KLineConfig.shared.wr10Color, "WR10"),
                (wr14Points, KLineConfig.shared.wr14Color, "WR14")
            ]
        )
    }
}
