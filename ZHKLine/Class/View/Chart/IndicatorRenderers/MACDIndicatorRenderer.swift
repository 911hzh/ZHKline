//
//  MACDIndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// MACD指标绘制器
class MACDIndicatorRenderer: BaseIndicatorRenderer {
    
    override func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        // 创建MACD专用layer
        let macdLayer = KLineBaseLayer()
        macdLayer.frame = frame
        
        // 获取MACD数据范围
        let macdValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.macd }
        let difValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.dif }
        let deaValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.dea }
        
        guard !macdValues.isEmpty else { return macdLayer }
        
        let allValues = macdValues + difValues + deaValues
        guard let maxValue = allValues.max(),
              let minValue = allValues.min(),
              maxValue != minValue else { return macdLayer }
        
        // 在MACD layer内绘制（使用layer内部坐标系）
        drawMACDBarChart(on: macdLayer, layerSize: frame.size, valueRange: (minValue, maxValue), klineModels: klineModels, positionModels: positionModels)
        drawMACDLines(on: macdLayer, layerSize: frame.size, valueRange: (minValue, maxValue), klineModels: klineModels, positionModels: positionModels)
        
        return macdLayer
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
            title: "MACD:",
            titleColor: KLineConfig.shared.macdDifColor,
            values: [
                ("DIF", indicators.dif, KLineConfig.shared.macdDifColor),
                ("DEA", indicators.dea, KLineConfig.shared.macdDeaColor),
                ("MACD", indicators.macd, KLineConfig.shared.indicatorTextColor)
            ]
        )
    }
    
    // MARK: - 私有绘制方法
    
    /// 在指定layer上绘制MACD柱状图
    private func drawMACDBarChart(on layer: KLineBaseLayer, layerSize: CGSize, valueRange: (Double, Double), klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 分别创建正负MACD柱状图路径
        let positiveBarPath = UIBezierPath()
        let negativeBarPath = UIBezierPath()
        let centerY = layerSize.height / 2  // 使用layer内部坐标系中心位置
        let range = valueRange.1 - valueRange.0
        
        for (index, positionModel) in positionModels.enumerated() {
            if index < klineModels.count,
               let indicators = klineModels[index].KLineTechnicalIndicatorsModel,
               let macd = indicators.macd {
                
                let normalizedValue = (macd - valueRange.0) / range
                // 使用layer内部坐标系计算
                let yPosition = layerSize.height - (normalizedValue * layerSize.height)
                let barHeight = abs(yPosition - centerY)
                let isPositive = macd >= 0
                
                // 使用配置文件中的MACD柱状图宽度比例
                let barWidth = KLineConfig.shared.candleWidth * KLineConfig.shared.macdBarWidthRatio
                
                // 绘制柱子（使用layer内部坐标）
                let barRect = CGRect(
                    x: positionModel.candleCenterX - barWidth / 2,
                    y: centerY - (isPositive ? barHeight : 0),
                    width: barWidth,
                    height: barHeight
                )
                
                let rectPath = UIBezierPath(rect: barRect)
                
                // 根据正负值添加到不同路径
                if isPositive {
                    positiveBarPath.append(rectPath)
                } else {
                    negativeBarPath.append(rectPath)
                }
            }
        }
        
        // 创建正值柱状图层（使用上涨颜色）并添加到指定layer
        if !positiveBarPath.isEmpty {
            let positiveBarLayer = KLineBaseLayer()
            positiveBarLayer.path = positiveBarPath.cgPath
            positiveBarLayer.fillColor = KLineConfig.shared.candleUpColor.cgColor
            positiveBarLayer.strokeColor = UIColor.clear.cgColor
            positiveBarLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            layer.addSublayer(positiveBarLayer)
        }
        
        // 创建负值柱状图层（使用下跌颜色）并添加到指定layer
        if !negativeBarPath.isEmpty {
            let negativeBarLayer = KLineBaseLayer()
            negativeBarLayer.path = negativeBarPath.cgPath
            negativeBarLayer.fillColor = KLineConfig.shared.candleDownColor.cgColor
            negativeBarLayer.strokeColor = UIColor.clear.cgColor
            negativeBarLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            layer.addSublayer(negativeBarLayer)
        }
    }
    
    /// 在指定layer上绘制MACD线
    private func drawMACDLines(on layer: KLineBaseLayer, layerSize: CGSize, valueRange: (Double, Double), klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 计算DIF线位置
        let difPoints = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.dif },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        // 计算DEA线位置
        let deaPoints = calculateLinePoints(
            layerSize: layerSize,
            valueRange: valueRange,
            valueExtractor: { indicators in indicators.dea },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        drawLineChart(
            on: layer,
            layerSize: layerSize,
            points: [
                (difPoints, KLineConfig.shared.macdDifColor, "DIF"),
                (deaPoints, KLineConfig.shared.macdDeaColor, "DEA")
            ]
        )
    }
    
    /// 计算MACD标签
    func calculateMACDLabel(position: Int, totalPositions: Int, klineModels: [KLineModel]) -> String {
        guard !klineModels.isEmpty else { return "0" }
        
        let macdValues = klineModels.compactMap { $0.KLineTechnicalIndicatorsModel?.macd }
        guard !macdValues.isEmpty else { return "0" }
        
        let maxMacd = macdValues.max() ?? 0
        let minMacd = macdValues.min() ?? 0
        let range = max(abs(maxMacd), abs(minMacd))
        
        let ratio = 1.0 - Double(position) / Double(totalPositions - 1)
        let value = range * (ratio * 2 - 1) // 从-range到+range
        
        return String(format: "%.2f", value)
    }
}
