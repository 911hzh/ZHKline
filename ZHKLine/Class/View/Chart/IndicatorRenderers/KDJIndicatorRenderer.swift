//
//  KDJIndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// KDJ指标绘制器
class KDJIndicatorRenderer: BaseIndicatorRenderer {
    
    override func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        // 创建KDJ专用layer
        let kdjLayer = KLineBaseLayer()
        kdjLayer.frame = frame
        
        // 获取KDJ数据的实际范围
        let kValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.k }
        let dValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.d }
        let jValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.j }
        
        let allValues = kValues + dValues + jValues
        guard !allValues.isEmpty else { return kdjLayer }
        
        let minValue = allValues.min()!
        let maxValue = allValues.max()!
        
        // 确保有一定的范围，避免minValue == maxValue
        let range = maxValue - minValue
        let adjustedMin = range > 0 ? minValue : minValue - 5
        let adjustedMax = range > 0 ? maxValue : maxValue + 5
        
        let valueRange = (min: adjustedMin, max: adjustedMax)
        
        // 在KDJ layer内绘制（使用layer内部坐标系）
        drawKDJLines(on: kdjLayer, layerSize: frame.size, valueRange: valueRange, klineModels: klineModels, positionModels: positionModels)
        
        return kdjLayer
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
            title: "KDJ:",
            titleColor: KLineConfig.shared.kdjKColor,
            values: [
                ("K", indicators.k, KLineConfig.shared.kdjKColor),
                ("D", indicators.d, KLineConfig.shared.kdjDColor),
                ("J", indicators.j, KLineConfig.shared.kdjJColor)
            ]
        )
    }
    
    // MARK: - 私有绘制方法
    
    /// 在指定layer上绘制KDJ线
    private func drawKDJLines(on layer: KLineBaseLayer, layerSize: CGSize, valueRange: (min: Double, max: Double), klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 计算K、D、J线位置
        let kPoints = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.k },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let dPoints = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.d },
            klineModels: klineModels,
            positionModels: positionModels
        )
        let jPoints = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.j },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        drawLineChart(
            on: layer,
            layerSize: layerSize,
            points: [
                (kPoints, KLineConfig.shared.kdjKColor, "K"),
                (dPoints, KLineConfig.shared.kdjDColor, "D"),
                (jPoints, KLineConfig.shared.kdjJColor, "J")
            ]
        )
    }
}
