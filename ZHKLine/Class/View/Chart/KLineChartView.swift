//
//  KLineContentView.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import UIKit
class KLineChartView: UIView {
    /**
     主图的的交叉轴图
     */
    private var crosscCandleLayer: CAShapeLayer = CAShapeLayer()
    /**
     蜡烛图
     */
    private var candleLayers: CAShapeLayer = CAShapeLayer()
    /**
     指标图
     */
    private var seconedLayer: KLineSeconedLayer = KLineSeconedLayer(itemHeight: 0, needDrawTypes: [])

    
    /// 十字线容器层（包含线条、圆点和日期标签）
    private var crossLineContainerLayer: CALayer = CALayer()
    
    /**
     用于显示的数组源
     */
    private var datas: [KLineModel] = []
    /**
     和显示数据源对应的位置信息记录器
     */
    private var positionDatas: [KLinePositionModel] = []
    /**
     加个区间记录器
     */
    private var priceRange: (maxPrice: CGFloat, minPrice: CGFloat) = (0,0)
    /**
     当前选择指标
     */
    var selectIndicatorTypes: [KLineTechnicalIndicatorType] = []
    
    /** 主图技术指标选择
     */
    var mainChartIndicatorSelection: [KLineTechnicalIndicatorType] = [] {
        didSet {
            drawUI()
        }
    }
    
    /// 当前选中的K线数据，用于更新副图指标标签显示
    var selectedKLineModel: KLineModel?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /**
     设置可见区域的模型数据，那么就会发生重绘
     */
    func setDatas(
        newDatas: [KLineModel],
        positionDatas: [KLinePositionModel],
        offset: CGFloat,
        indexBound: (begin: Int, end: Int),
        priceRange: (maxPrice: CGFloat, minPrice: CGFloat),
        selectIndicatorTyps: [KLineTechnicalIndicatorType]
    ) {
        self.datas = newDatas
        self.priceRange = priceRange
        self.positionDatas = positionDatas
        self.selectIndicatorTypes = selectIndicatorTyps
        drawUI()
    }
    
    
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("deinit \(self)")
    }
    
    
    
    
}
// MARK: - 绘制相关
extension KLineChartView {
    /// 简化的显示更新（技术指标位置已包含在positionDatas中）
    private func drawUI() {
        guard !datas.isEmpty, !positionDatas.isEmpty else { return }
        drawCrossLayer()
        drawCrandleLayer()
        drawSeconedLayer()
        // 确保十字线层级正确（在指标层之上，但在detail之下）
        ensureCrossLineLayerOrder()
    }
    private func drawCrossLayer() {
        crosscCandleLayer.removeFromSuperlayer()
        crosscCandleLayer = KLineLayerUtil.createCrossLayer(
            size: CGSize(width: frame.width - KLineConfig.shared.chartViewPadding.left - KLineConfig.shared.chartViewPadding.left - KLineConfig.shared.chartViewPadding.right, height: KLineConfig.shared.mainCanvasHeight),
            topHeight: KLineConfig.shared.crandleInsets.top,
            bottomHeight: KLineConfig.shared.crandleInsets.bottom,
            horLine: KLineConfig.shared.crossHorCount,
            verticalLine: KLineConfig.shared.crossVerticalCount,
            lineWidth: KLineConfig.shared.crossLineWidth,
            lineColor: KLineConfig.shared.crossLineColor,
            horLineText: KLineLayerUtil.createHorShowTexts(lineCount: KLineConfig.shared.crossHorCount, maxPrice: priceRange.maxPrice, minPrice: priceRange.minPrice),
            verticalLineText: KLineLayerUtil.createVerticalShowTexts(lineCount: KLineConfig.shared.crossVerticalCount, klineModels: datas)
        )
        layer.addSublayer(crosscCandleLayer)
        crosscCandleLayer.frame = CGRect(x: KLineConfig.shared.chartViewPadding.left, y: 0, width: frame.size.width-KLineConfig.shared.chartViewPadding.left - KLineConfig.shared.chartViewPadding.right, height: KLineConfig.shared.mainCanvasHeight)
    }
    private func drawCrandleLayer() {
        candleLayers.removeFromSuperlayer()
        // 直接使用包含技术指标位置的positionDatas创建蜡烛图层
        candleLayers = KLineLayerUtil.createCrandleLayer(
            datas: datas,
            positionDatas: positionDatas,
            indexBound: (0, datas.count-1),
            indicatorSelection: mainChartIndicatorSelection
        )
        
        candleLayers.frame = CGRect(x: KLineConfig.shared.crandleInsets.left, y: KLineConfig.shared.crandleInsets.top, width: bounds.size.width-KLineConfig.shared.crandleInsets.left-KLineConfig.shared.crandleInsets.right, height: KLineConfig.shared.mainCanvasHeight-KLineConfig.shared.crandleInsets.top-KLineConfig.shared.crandleInsets.bottom)
        layer.addSublayer(candleLayers)
    }
    private func drawSeconedLayer() {
        seconedLayer.removeFromSuperlayer()
        seconedLayer = KLineSeconedLayer(itemHeight: KLineConfig.shared.crossItemHeight, needDrawTypes: self.selectIndicatorTypes)
        seconedLayer.frame = CGRect(x: KLineConfig.shared.chartViewPadding.left, y: crosscCandleLayer.frame.origin.y + crosscCandleLayer.frame.size.height, width: frame.size.width-KLineConfig.shared.chartViewPadding.left - KLineConfig.shared.chartViewPadding.right, height: KLineConfig.shared.getSecoendHeight(indicatorTypes: selectIndicatorTypes))
        layer.addSublayer(seconedLayer)
        seconedLayer.drawIndicators(klineModels: datas, positions: positionDatas, selectedKLineModel: selectedKLineModel)
    }
    
    /// 显示十字线
    /// - Parameters:
    ///   - point: 交叉点位置
    func showCrossLine(at point: CGPoint) {
        showCrossLine(at: point, selectedKLineModel: selectedKLineModel)
    }
    
    /// 显示十字线（带选中数据）
    /// - Parameters:
    ///   - point: 交叉点位置
    ///   - selectedKLineModel: 选中的K线数据（用于显示日期）
    func showCrossLine(at point: CGPoint, selectedKLineModel: KLineModel?) {
        // 移除之前的十字线容器
        crossLineContainerLayer.removeFromSuperlayer()
        
        // 获取配置参数
        let config = KLineConfig.shared
        let secondLayerHeight = config.getSecoendHeight(indicatorTypes: selectIndicatorTypes)
        
        // 计算各种坐标
        let verticalLineTopY = config.crandleInsets.top
        let verticalLineBottomY = config.mainCanvasHeight + secondLayerHeight
        let horizontalLineLeftX = config.crandleInsets.left
        let horizontalLineRightX = bounds.width - config.crandleInsets.right
        
        // 使用KLineLayerUtil创建十字线容器
        crossLineContainerLayer = KLineLayerUtil.createCrossLineContainer(
            point: point,
            containerSize: bounds.size,
            verticalLineTopY: verticalLineTopY,
            verticalLineBottomY: verticalLineBottomY,
            horizontalLineLeftX: horizontalLineLeftX,
            horizontalLineRightX: horizontalLineRightX,
            crossLineColor: config.crossLineColor,
            crossLineWidth: config.crossLineWidth,
            selectedKLineModel: selectedKLineModel,
            bottomHeight: config.crandleInsets.bottom,
            lineWidth: config.crossLineWidth
        )
        
        // 添加到视图层
        layer.addSublayer(crossLineContainerLayer)
    }
    
    /// 隐藏十字线
    func hideCrossLine() {
        crossLineContainerLayer.removeFromSuperlayer()
    }
    
    /// 确保十字线层级正确
    private func ensureCrossLineLayerOrder() {
        // 如果十字线容器层已经存在，移除它然后重新添加到正确的位置
        if crossLineContainerLayer.superlayer != nil {
            crossLineContainerLayer.removeFromSuperlayer()
            // 添加到所有其他层的最上面，但会在detail视图之下（因为detail在父视图中）
            layer.addSublayer(crossLineContainerLayer)
        }
    }
}
