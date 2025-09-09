//
//  IndicatorRenderer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

/// 指标绘制器协议
protocol IndicatorRenderer {
    /// 创建并绘制指标内容层
    /// - Parameters:
    ///   - frame: 绘制区域
    ///   - klineModels: K线数据
    ///   - positionModels: K线位置信息
    /// - Returns: 绘制好的指标内容层
    func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer
    
    /// 创建坐标轴标签层
    /// - Parameters:
    ///   - frame: 绘制区域
    ///   - indicatorType: 指标类型
    ///   - klineModels: K线数据（用于计算数据范围）
    /// - Returns: 坐标轴标签层
    func createCoordinateLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel]) -> [CALayer]
    
    /// 创建指标数值标签层
    /// - Parameters:
    ///   - frame: 绘制区域
    ///   - indicatorType: 指标类型
    ///   - klineModels: K线数据
    ///   - selectedKLineModel: 当前选中的K线数据（如果有的话）
    /// - Returns: 指标数值标签层数组
    func createIndicatorValueLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel], selectedKLineModel: KLineModel?) -> [CALayer]
}

/// 基础指标绘制器，提供通用方法
class BaseIndicatorRenderer: IndicatorRenderer {
    
    /// 创建并绘制指标内容层（子类需要重写）
    func createRender(frame: CGRect, klineModels: [KLineModel], positionModels: [KLinePositionModel]) -> KLineBaseLayer {
        fatalError("子类必须重写此方法")
    }
    
    /// 创建坐标轴标签层
    func createCoordinateLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel]) -> [CALayer] {
        var layers: [CALayer] = []
        
        // 添加指标名称标签
        layers.append(createIndicatorNameLabel(frame: frame, indicatorType: indicatorType))
        
        // 添加Y轴数值标签
        layers.append(contentsOf: createYAxisValueLabels(frame: frame, indicatorType: indicatorType, klineModels: klineModels))
        
        return layers
    }
    
    /// 创建指标数值标签层
    func createIndicatorValueLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel], selectedKLineModel: KLineModel?) -> [CALayer] {
        // 子类可以重写此方法提供特定的数值标签绘制逻辑
        return []
    }
    
    // MARK: - 通用绘制方法
    
    /// 计算线条位置点（使用layer内部坐标系）
    func calculateLinePoints(
        layerSize: CGSize,
        valueRange: (min: Double, max: Double),
        valueExtractor: (KLineTechnicalIndicatorsModel) -> Double?,
        klineModels: [KLineModel],
        positionModels: [KLinePositionModel]
    ) -> [CGPoint] {
        var points: [CGPoint] = []
        let range = valueRange.max - valueRange.min
        
        for (index, positionModel) in positionModels.enumerated() {
            if index < klineModels.count,
               let indicators = klineModels[index].KLineTechnicalIndicatorsModel,
               let value = valueExtractor(indicators) {
                
                let normalizedValue = (value - valueRange.min) / range
                let yPosition = layerSize.height - (normalizedValue * layerSize.height)
                let point = CGPoint(x: positionModel.candleCenterX, y: yPosition)
                points.append(point)
            }
        }
        
        return points
    }
    
    /// 在指定layer上绘制通用折线图
    func drawLineChart(on layer: KLineBaseLayer, layerSize: CGSize, points: [(points: [CGPoint], color: UIColor, name: String)]) {
        for lineData in points {
            guard lineData.points.count > 1 else { continue }
            
            let lineLayer = KLineBaseLayer()
            let linePath = UIBezierPath()
            
            linePath.move(to: lineData.points[0])
            
            for i in 1..<lineData.points.count {
                linePath.addLine(to: lineData.points[i])
            }
            
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = lineData.color.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = KLineConfig.shared.indicatorLineWidth
            lineLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            layer.addSublayer(lineLayer)
        }
    }
    
    // MARK: - 标签创建方法
    
    /// 创建指标名称标签
    private func createIndicatorNameLabel(frame: CGRect, indicatorType: KLineTechnicalIndicatorType) -> CATextLayer {
        let labelLayer = CATextLayer()
        labelLayer.frame = CGRect(x: frame.width - 60, y: frame.minY + 5, width: 55, height: 15)
        labelLayer.fontSize = 10
        labelLayer.foregroundColor = UIColor.systemGray.cgColor
        labelLayer.alignmentMode = .right
        labelLayer.contentsScale = UIScreen.main.scale
        
        switch indicatorType {
        case .volume:
            labelLayer.string = "VOL"
        case .macd:
            labelLayer.string = "MACD"
        case .kdj:
            labelLayer.string = "KDJ"
        case .rsi:
            labelLayer.string = "RSI"
        case .wr:
            labelLayer.string = "WR"
        default:
            break
        }
        
        return labelLayer
    }
    
    /// 创建Y轴数值标签
    private func createYAxisValueLabels(frame: CGRect, indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel]) -> [CATextLayer] {
        let labelCount = 3
        let labelHeight: CGFloat = 12
        let labelWidth: CGFloat = 50
        var labels: [CATextLayer] = []
        
        // 计算该指标的数据范围
        let valueRange = calculateValueRange(for: indicatorType, klineModels: klineModels)
        
        for i in 0..<labelCount {
            let labelLayer = CATextLayer()
            let yPosition = frame.minY + (frame.height - labelHeight) * CGFloat(i) / CGFloat(labelCount - 1)
            
            labelLayer.frame = CGRect(
                x: frame.width - labelWidth - 5,
                y: yPosition,
                width: labelWidth,
                height: labelHeight
            )
            labelLayer.fontSize = 9
            labelLayer.foregroundColor = UIColor.systemGray2.cgColor
            labelLayer.alignmentMode = .right
            labelLayer.contentsScale = UIScreen.main.scale
            
            let labelValue = calculateLabelValue(
                indicatorType: indicatorType,
                position: i,
                totalPositions: labelCount,
                valueRange: valueRange
            )
            labelLayer.string = labelValue
            
            labels.append(labelLayer)
        }
        
        return labels
    }
    
    /// 计算标签数值（子类可以重写提供特定逻辑）
    func calculateLabelValue(indicatorType: KLineTechnicalIndicatorType, position: Int, totalPositions: Int, frame: CGRect) -> String {
        // 默认返回空字符串，让子类重写提供具体的数值范围
        return ""
    }
    
    /// 计算标签数值（使用实际数据范围）
    func calculateLabelValue(indicatorType: KLineTechnicalIndicatorType, position: Int, totalPositions: Int, valueRange: (min: Double, max: Double)) -> String {
        // 计算当前位置对应的实际数值
        let ratio = Double(totalPositions - 1 - position) / Double(totalPositions - 1) // 从上到下：最大值到最小值
        let value = valueRange.min + ratio * (valueRange.max - valueRange.min)
        
        switch indicatorType {
        case .kdj, .rsi:
            return String(format: "%.1f", value)
        case .wr:
            return String(format: "%.1f", value)
        case .volume:
            return formatVolumeValue(value)
        case .macd:
            return String(format: "%.4f", value)
        default:
            return String(format: "%.2f", value)
        }
    }
    
    /// 格式化成交量数值
    private func formatVolumeValue(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", value / 1_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    /// 计算指标的数据范围
    private func calculateValueRange(for indicatorType: KLineTechnicalIndicatorType, klineModels: [KLineModel]) -> (min: Double, max: Double) {
        var allValues: [Double] = []
        
        for klineModel in klineModels {
            guard let indicators = klineModel.KLineTechnicalIndicatorsModel else { continue }
            
            switch indicatorType {
            case .kdj:
                if let k = indicators.k { allValues.append(k) }
                if let d = indicators.d { allValues.append(d) }
                if let j = indicators.j { allValues.append(j) }
            case .rsi:
                if let rsi6 = indicators.rsi6 { allValues.append(rsi6) }
                if let rsi12 = indicators.rsi12 { allValues.append(rsi12) }
                if let rsi24 = indicators.rsi24 { allValues.append(rsi24) }
            case .wr:
                if let wr6 = indicators.wr6 { allValues.append(wr6) }
                if let wr10 = indicators.wr10 { allValues.append(wr10) }
                if let wr14 = indicators.wr14 { allValues.append(wr14) }
            case .volume:
                if let volume = indicators.volumeMA5 { allValues.append(volume) }
                if let volume = indicators.volumeMA10 { allValues.append(volume) }
            case .macd:
                if let dif = indicators.dif { allValues.append(dif) }
                if let dea = indicators.dea { allValues.append(dea) }
                if let macd = indicators.macd { allValues.append(macd) }
            default:
                break
            }
        }
        
        guard !allValues.isEmpty else {
            return (min: 0.0, max: 100.0) // 默认范围
        }
        
        let minValue = allValues.min()!
        let maxValue = allValues.max()!
        
        // 确保有一定的范围，避免minValue == maxValue
        let range = maxValue - minValue
        let adjustedMin = range > 0 ? minValue : minValue - 5
        let adjustedMax = range > 0 ? maxValue : maxValue + 5
        
        return (min: adjustedMin, max: adjustedMax)
    }
    
    /// 创建副图指标标签的通用方法
    func createSecondaryIndicatorLabels(
        xOffset: CGFloat,
        yPosition: CGFloat,
        labelHeight: CGFloat,
        spacing: CGFloat,
        title: String,
        titleColor: UIColor,
        values: [(name: String, value: Double?, color: UIColor)]
    ) -> [CATextLayer] {
        var currentX = xOffset
        var labels: [CATextLayer] = []
        
        // 创建指标类型标题
        let titleLabel = CATextLayer()
        titleLabel.string = title
        titleLabel.font = UIFont.systemFont(ofSize: 8)
        titleLabel.fontSize = 8
        titleLabel.foregroundColor = titleColor.cgColor
        titleLabel.backgroundColor = UIColor.clear.cgColor
        titleLabel.alignmentMode = .left
        titleLabel.contentsScale = UIScreen.main.scale
        
        let titleSize = (title as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 8)])
        titleLabel.frame = CGRect(x: currentX, y: yPosition, width: titleSize.width, height: labelHeight)
        labels.append(titleLabel)
        currentX += titleSize.width + spacing
        
        // 创建各个数值标签
        for valueData in values {
            if let value = valueData.value {
                let valueLabel = CATextLayer()
                valueLabel.string = "\(valueData.name):\(String(format: "%.2f", value))"
                valueLabel.font = UIFont.systemFont(ofSize: 8)
                valueLabel.fontSize = 8
                valueLabel.foregroundColor = valueData.color.cgColor
                valueLabel.backgroundColor = UIColor.clear.cgColor
                valueLabel.alignmentMode = .left
                valueLabel.contentsScale = UIScreen.main.scale
                
                let valueText = "\(valueData.name):\(String(format: "%.2f", value))"
                let valueSize = (valueText as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 8)])
                valueLabel.frame = CGRect(x: currentX, y: yPosition, width: valueSize.width, height: labelHeight)
                labels.append(valueLabel)
                currentX += valueSize.width + spacing
            }
        }
        
        return labels
    }
}
