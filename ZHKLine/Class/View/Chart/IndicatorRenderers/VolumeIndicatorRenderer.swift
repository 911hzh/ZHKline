//
//  VolumeIndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// 成交量指标绘制器
class VolumeIndicatorRenderer: BaseIndicatorRenderer {
    
    override func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        // 创建VOL专用layer
        let volLayer = KLineBaseLayer()
        volLayer.frame = frame
        
        // 获取成交量数据
        let volumes = klineModels.map { $0.volume }
        guard let maxVolume = volumes.max(), maxVolume > 0 else { return volLayer }
        
        // 在VOL layer内绘制（使用layer内部坐标系）
        drawVolumeBarChart(on: volLayer, layerSize: frame.size, maxVolume: maxVolume, klineModels: klineModels, positionModels: positionModels)
        drawVolumeMALines(on: volLayer, layerSize: frame.size, maxVolume: maxVolume, klineModels: klineModels, positionModels: positionModels)
        
        return volLayer
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
            title: "VOL:",
            titleColor: KLineConfig.shared.volumeMA5Color,
            values: [
                ("MA5", indicators.volumeMA5, KLineConfig.shared.volumeMA5Color),
                ("MA10", indicators.volumeMA10, KLineConfig.shared.volumeMA10Color)
            ]
        )
    }
    
    // MARK: - 私有绘制方法
    
    /// 在指定layer上绘制成交量柱状图
    private func drawVolumeBarChart(on layer: KLineBaseLayer, layerSize: CGSize, maxVolume: Double, klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 分别创建涨跌柱状图路径
        let upBarPath = UIBezierPath()
        let downBarPath = UIBezierPath()
        
        for (index, positionModel) in positionModels.enumerated() {
            if index < klineModels.count {
                let volume = klineModels[index].volume
                let height = layerSize.height * 0.8 * CGFloat(volume / maxVolume)
                let yPosition = layerSize.height - height
                let isRising = klineModels[index].isRising
                
                let barWidth = KLineConfig.shared.candleWidth * KLineConfig.shared.volumeBarWidthRatio
                
                let barRect = CGRect(
                    x: positionModel.candleCenterX - barWidth / 2,
                    y: yPosition,
                    width: barWidth,
                    height: height
                )
                
                let rectPath = UIBezierPath(rect: barRect)
                
                if isRising {
                    upBarPath.append(rectPath)
                } else {
                    downBarPath.append(rectPath)
                }
            }
        }
        
        // 创建涨势柱状图层并添加到指定layer
        if !upBarPath.isEmpty {
            let upBarLayer = KLineBaseLayer()
            upBarLayer.path = upBarPath.cgPath
            upBarLayer.fillColor = KLineConfig.shared.candleUpColor.cgColor
            upBarLayer.strokeColor = UIColor.clear.cgColor
            upBarLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            layer.addSublayer(upBarLayer)
        }
        
        // 创建跌势柱状图层并添加到指定layer
        if !downBarPath.isEmpty {
            let downBarLayer = KLineBaseLayer()
            downBarLayer.path = downBarPath.cgPath
            downBarLayer.fillColor = KLineConfig.shared.candleDownColor.cgColor
            downBarLayer.strokeColor = UIColor.clear.cgColor
            downBarLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            layer.addSublayer(downBarLayer)
        }
    }
    
    /// 在指定layer上绘制成交量移动平均线
    private func drawVolumeMALines(on layer: KLineBaseLayer, layerSize: CGSize, maxVolume: Double, klineModels: [KLineModel], positionModels: [KLinePositionModel]) {
        // 计算成交量MA5线位置
        let volumeMA5Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: (0, maxVolume),
            valueExtractor: { indicators in indicators.volumeMA5 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        // 计算成交量MA10线位置
        let volumeMA10Points = calculateLinePoints(
            layerSize: layerSize,
            valueRange: (0, maxVolume),
            valueExtractor: { indicators in indicators.volumeMA10 },
            klineModels: klineModels,
            positionModels: positionModels
        )
        
        drawLineChart(
            on: layer,
            layerSize: layerSize,
            points: [
                (volumeMA5Points, KLineConfig.shared.volumeMA5Color, "MA5"),
                (volumeMA10Points, KLineConfig.shared.volumeMA10Color, "MA10")
            ]
        )
    }
    
    /// 计算成交量标签
    func calculateVolumeLabel(position: Int, totalPositions: Int, klineModels: [KLineModel]) -> String {
        guard !klineModels.isEmpty else { return "0" }
        
        let volumes = klineModels.map { $0.volume }
        let maxVolume = volumes.max() ?? 0
        
        let ratio = 1.0 - Double(position) / Double(totalPositions - 1)
        let value = maxVolume * ratio
        
        if value >= 1000000000 {
            return String(format: "%.1fB", value / 1000000000)
        } else if value >= 1000000 {
            return String(format: "%.1fM", value / 1000000)
        } else if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}
