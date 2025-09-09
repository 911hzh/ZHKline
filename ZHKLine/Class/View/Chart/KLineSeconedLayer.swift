//
//  KLineSeconedLayer.swift
//  ZHKLine
//
//  Created by huang on 2025/9/2.
//

import Foundation
import UIKit

class KLineSeconedLayer: KLineBaseLayer {
    private var needDrawTypes: [KLineTechnicalIndicatorType] = []
    private var itemHeight: CGFloat = 0
    private var klineModels: [KLineModel] = []
    private var positionModels: [KLinePositionModel] = []
    
    init(itemHeight: CGFloat, needDrawTypes: [KLineTechnicalIndicatorType]) {
        self.itemHeight = itemHeight
        self.needDrawTypes = needDrawTypes
        super.init()
    }
    
    /// 绘制副图技术指标
    /// - Parameters:
    ///   - klineModels: K线数据
    ///   - positions: K线位置信息数组（用于获取X坐标）
    ///   - selectedKLineModel: 当前选中的K线数据（可选）
    func drawIndicators(klineModels: [KLineModel], positions: [KLinePositionModel], selectedKLineModel: KLineModel? = nil) {
        self.klineModels = klineModels
        self.positionModels = positions
        
        // 清空之前的绘制
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 绘制背景网格
        drawBackgroundGrid()
        
        // 为每个副图指标动态计算位置并绘制
        for (index, indicatorType) in needDrawTypes.enumerated() {
            let yOffset = itemHeight * CGFloat(index)
            let indicatorFrame = CGRect(x: 0, y: yOffset, width: frame.width, height: itemHeight)
            
            // 使用策略模式处理不同的指标绘制
            if let renderer = IndicatorRendererFactory.createRenderer(for: indicatorType) {
                // 创建并添加指标内容层
                let contentLayer = renderer.createRender(frame: indicatorFrame, klineModels: klineModels, positionModels: positions)
                addSublayer(contentLayer)
                
                // 创建并添加坐标轴标签层
                let coordinateLabels = renderer.createCoordinateLabels(frame: indicatorFrame, indicatorType: indicatorType, klineModels: klineModels)
                coordinateLabels.forEach { addSublayer($0) }
                
                // 创建并添加指标数值标签层
                let valueLabels = renderer.createIndicatorValueLabels(frame: indicatorFrame, indicatorType: indicatorType, klineModels: klineModels, selectedKLineModel: selectedKLineModel)
                valueLabels.forEach { addSublayer($0) }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 绘制方法扩展
extension KLineSeconedLayer {
    /// 绘制背景网格
    private func drawBackgroundGrid() {
        for (index, _) in needDrawTypes.enumerated() {
            let yOffset = itemHeight * CGFloat(index)
            let layer = createCrossLayer(
                size: CGSize(width: frame.width, height: itemHeight),
                bottomHeight: KLineConfig.shared.crossTopHeight,
                itemHeight: itemHeight,
                verticalLine: KLineConfig.shared.crossVerticalCount,
                needDrawTopHorLine: false,
                lineWidth: KLineConfig.shared.crossLineWidth,
                lineColor: KLineConfig.shared.crossLineColor
            )
            layer.frame = CGRect(x: 0, y: yOffset, width: frame.width, height: itemHeight)
            addSublayer(layer)
        }
    }
}

fileprivate func createCrossLayer(
    size: CGSize,
    bottomHeight: CGFloat,
    itemHeight: CGFloat,
    verticalLine: Int,
    needDrawTopHorLine: Bool,
    lineWidth: CGFloat,
    lineColor: UIColor
) -> CAShapeLayer {
    let layer = KLineBaseLayer()
    let uiBezierPath = UIBezierPath()
    
    // 计算偏移量以避免边界裁剪
    let offset = lineWidth / 2.0
    
    if needDrawTopHorLine {
        // 绘制顶部边界线
        uiBezierPath.move(to: CGPoint(x: offset, y: offset))
        uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: offset))
    }
    let itemWidth = (size.width - offset * 2) / CGFloat(verticalLine - 1)
    // 绘制中间的那条线
    uiBezierPath.move(to: CGPoint(x: offset, y: itemHeight - 20))
    uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: itemHeight - 20))
    
    // 绘制底部的那条线
    uiBezierPath.move(to: CGPoint(x: offset, y: itemHeight - offset))
    uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: itemHeight - offset))
    
    // 绘制底部边界线
    uiBezierPath.move(to: CGPoint(x: offset, y: size.height - offset))
    uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: size.height - offset))
    
    var lastX: CGFloat = offset
    
    // 绘制竖线
    for _ in 0 ..< verticalLine {
        uiBezierPath.move(to: CGPoint(x: lastX, y: offset))
        uiBezierPath.addLine(to: CGPoint(x: lastX, y: size.height - offset))
        lastX += itemWidth
    }
    
    layer.path = uiBezierPath.cgPath
    layer.strokeColor = lineColor.cgColor
    layer.lineWidth = lineWidth
    layer.fillColor = UIColor.clear.cgColor
    return layer
}
