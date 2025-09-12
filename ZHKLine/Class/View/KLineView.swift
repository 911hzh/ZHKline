//
//  KLineView.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import UIKit
class KLineView: UIView {
    private let scrollView = UIScrollView()
    private let chartView: KLineChartView
    private let indicatorControlView: KTechnicalIndicatorControlView
    private var datas: [KLineModel] = []
    var heightChanged: ((_ height: CGFloat) -> Void)?
    private lazy var scaleGestureManager: KLineScaleGestureManager = {
        let gesture = KLineScaleGestureManager(delegate: self)
        return gesture
    }()
    private lazy var gestureManager: KLineTapLongGestureManager = {
        let gesture = KLineTapLongGestureManager(delegate: self)
        return gesture
    }()
    /**
     当前选择指标类型
     */
    private var selectIndicatorTypes: [KLineTechnicalIndicatorType] = []
    // 详情视图
    private var detailView: KLineDetailView?
    
    // 当前选中的K线数据，用于保持主图技术指标显示，如果为nil则使用datas.first
    private var selectedKLineModel: KLineModel?
    
    // 是否显示十字线
    private var shouldShowCrossLine: Bool = false
    
    // 十字线的位置
    private var crossLinePoint: CGPoint = .zero
    
    override init(frame: CGRect) {
        // 计算控制视图高度
        chartView = KLineChartView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.width, height: KLineConfig.shared.mainCanvasHeight)))
        indicatorControlView = KTechnicalIndicatorControlView(frame: CGRect(x: 0, y: KLineConfig.shared.mainCanvasHeight, width: frame.width, height: KLineConfig.shared.indicatorTypeControlHeight))
        super.init(frame: frame)
        
        // 设置滚动视图
        addSubview(scrollView)
        scrollView.addSubview(chartView)
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: KLineConfig.shared.getAllHeight(indicatorTypes: selectIndicatorTypes))
        scrollView.bounces = false
        scrollView.delegate = self
        
        // 添加技术指标控制视图
        addSubview(indicatorControlView)
        indicatorControlView.delegate = self
        
        // 设置缩放手势管理器
        setupScaleGestureManager()
        
        // 设置点击和长按手势管理器
        setupGestureManager()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        var indicatoryFrame = indicatorControlView.frame
        indicatoryFrame.origin.y = self.bounds.size.height - KLineConfig.shared.indicatorTypeControlHeight
        self.indicatorControlView.frame = indicatoryFrame
    }
    private func drawUI() {
        scrollView.frame = self.bounds
        let result = KLineCrandleIndexUtil.computerSize(datas: datas, drawMaxWidth: frame.width-KLineConfig.shared.crandleInsets.left-KLineConfig.shared.crandleInsets.right, offset: scrollView.contentOffset.x, crandleWidth: KLineConfig.shared.candleWidth, crandleSpace: KLineConfig.shared.candleSpace, totalHeight: KLineConfig.shared.mainCanvasHeight-KLineConfig.shared.crandleInsets.top-KLineConfig.shared.crandleInsets.bottom, indicatorSelection: chartView.mainChartIndicatorSelection)
        var oldFrame = chartView.frame
        oldFrame.origin.x = scrollView.contentOffset.x
        chartView.frame = oldFrame
        
        // 确保图表视图始终知道当前选中的数据
        chartView.selectedKLineModel = selectedKLineModel
        
        chartView.setDatas(
            newDatas: result.showDatas,
            positionDatas: result.positionModels,
            offset: scrollView.contentOffset.x,
            indexBound: (result.indexBegin, result.indexEnd),
            priceRange: (result.maxPrice, result.minPrice),
            selectIndicatorTyps: selectIndicatorTypes
        )
        
        // 更新主图技术指标显示
        // 如果没有选中任何数据，显示第一条数据的指标；如果有选中数据，保持显示选中的数据
        
        // 重绘十字线（如果需要显示）
        drawCrossLineIfNeeded()
        let modelToDisplay = selectedKLineModel ?? datas.first
        updateMainChartIndicators(with: modelToDisplay)
        
        let contentWidth = (KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace) * CGFloat(datas.count) + KLineConfig.shared.crandleInsets.left + KLineConfig.shared.crandleInsets.right + KLineConfig.shared.crossLineWidth*2
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.bounds.size.height)
    }
    
    /// 重绘十字线（如果需要显示）
    private func drawCrossLineIfNeeded() {
        if shouldShowCrossLine {
            chartView.showCrossLine(at: crossLinePoint, selectedKLineModel: selectedKLineModel)
        } else {
            chartView.hideCrossLine()
        }
    }
    func setupDatas(datas: [KLineModel]) {
        self.datas = datas
        drawUI()
    }
    func clearDatas() {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        selectedKLineModel = nil
        shouldShowCrossLine = false
        crossLinePoint = .zero
    }
    // MARK: - Setup Methods
    
    // /// 设置缩放手势管理器
    private func setupScaleGestureManager() {
        scaleGestureManager.addGestureToView(self)
    }
    
    // /// 设置点击和长按手势管理器
    private func setupGestureManager() {
        gestureManager.addGestureToView(self)
    }
    
    /// 更新ScrollView的内容大小和偏移量以适应缩放
    private func updateScrollViewForScaling() {
        // 计算新的内容宽度
        let contentWidth = (KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace) * CGFloat(datas.count) + 
                          KLineConfig.shared.crandleInsets.left + KLineConfig.shared.crandleInsets.right + 
                          KLineConfig.shared.crossLineWidth * 2
        
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.bounds.size.height)
        
        // 确保偏移量在有效范围内
        let maxOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        if scrollView.contentOffset.x > maxOffsetX {
            scrollView.contentOffset.x = maxOffsetX
        }
    }
    
    /// 更新主图技术指标显示
    private func updateMainChartIndicators(with selectedKLineModel: KLineModel?) {
        // 移除旧的指标标签视图
        chartView.subviews.forEach { view in
            if view is KMainIndicatorTextView {
                view.removeFromSuperview()
            }
        }
        
        // 创建新的指标标签视图
        let indicatorTextView = KMainIndicatorTextView()
        
        // 配置指标视图
        indicatorTextView.configure(
            selectedKLineModel: selectedKLineModel,
            config: KLineConfig.shared,
            selection: chartView.mainChartIndicatorSelection
        )
        
        // 添加到容器视图
        chartView.addSubview(indicatorTextView)
        
        // 设置约束
        indicatorTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorTextView.topAnchor.constraint(equalTo: chartView.topAnchor),
            indicatorTextView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            indicatorTextView.trailingAnchor.constraint(lessThanOrEqualTo: chartView.trailingAnchor)
        ])
    }
    
    // MARK: - DetailView Management
    
    /// 显示详细信息视图
    private func showDetailView(for data: KLineModel, at location: CGPoint) {
        // 判断显示位置（点击蜡烛左边部分固定显示在右边，点击蜡烛右边部分固定显示在左边）
        let preferRight = location.x < self.bounds.width / 2
        
        // 如果detailView不存在，创建新的
        if detailView == nil {
            detailView = KLineDetailView()
        }
        
        // 更新数据
        detailView?.updateData(data)
        
        // 如果还未显示，则显示它
        if detailView?.superview == nil {
            detailView?.show(at: location, in: self, preferRight: preferRight)
        } else {
            // 如果已经显示，只需要更新位置（如果需要）
            updateDetailViewPosition(at: location, preferRight: preferRight)
        }
    }
    
    /// 更新详细信息视图位置
    private func updateDetailViewPosition(at location: CGPoint, preferRight: Bool) {
        guard let detailView = detailView else { return }
        
        // 使用DetailView自己的动态尺寸计算
        let currentSize = detailView.frame.size
        let margin: CGFloat = 16
        
        var finalX: CGFloat
        let finalY: CGFloat = margin
        
        if preferRight {
            finalX = self.bounds.width - currentSize.width - margin
        } else {
            finalX = margin
        }
        
        // 更新frame，保持当前的动态计算尺寸
        detailView.frame = CGRect(x: finalX, y: finalY, width: currentSize.width, height: currentSize.height)
    }
    
    /// 隐藏详细信息视图
    private func hideDetailView() {
        detailView?.hide()
        detailView = nil
    }
    deinit {
        print("deinit \(self)")
    }
}

// MARK: - UIScrollViewDelegate

extension KLineView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果正在缩放，不处理scrollView的滚动事件，避免冲突
        if scaleGestureManager.isCurrentlyScaling {
            return
        }
        
        // 滑动时隐藏十字线
        gestureManager.resetSelection()
        
        print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")
        drawUI()
    }
}

// MARK: - KLineScaleGestureManagerDelegate

extension KLineView: KLineScaleGestureManagerDelegate {
    
    // MARK: - KLineScaleGestureManagerDelegate
    
    func dataModels(for manager: KLineScaleGestureManager) -> [KLineModel] {
        return datas
    }
    
    func scrollView(for manager: KLineScaleGestureManager) -> UIScrollView {
        return scrollView
    }
    
    func scaleGestureManagerShouldUpdateUI(_ manager: KLineScaleGestureManager) {
        drawUI()
    }
}

// MARK: - KTechnicalIndicatorControlViewDelegate

extension KLineView: KTechnicalIndicatorControlViewDelegate {
    
    func indicatorControlView(_ controlView: KTechnicalIndicatorControlView, didUpdateSelection types: [KLineTechnicalIndicatorType]) {
        // 分离主图和副图技术指标
        let mainChartTypes = types.filter { KLineTechnicalIndicatorType.mainTypes.contains($0) }
        let secondChartTypes = types.filter { KLineTechnicalIndicatorType.secondTypes.contains($0) }
        
        // 更新主图技术指标选择
        chartView.mainChartIndicatorSelection = mainChartTypes
        self.selectIndicatorTypes = secondChartTypes
        heightChanged?(KLineConfig.shared.getAllHeight(indicatorTypes: secondChartTypes))
        
        print("🔍 Updated [KLineTechnicalIndicatorType]: \(mainChartTypes)")
        
        // 重新绘制以应用新的技术指标选择
        drawUI()
    }
}

// MARK: - KLineTapLongGestureManagerDelegate

extension KLineView: KLineTapLongGestureManagerDelegate {
    
    func klineDataModels(for gestureManager: KLineTapLongGestureManager) -> [KLineModel] {
        return datas
    }
    
    func scrollView(for gestureManager: KLineTapLongGestureManager) -> UIScrollView {
        return scrollView
    }
    
    func candleLayerFrame(for gestureManager: KLineTapLongGestureManager) -> CGRect {
        // 获取containerView（KLineChartView）中candleLayers的frame
        // 需要转换为相对于KLineView的坐标
        let candleFrame = CGRect(
            x: KLineConfig.shared.crandleInsets.left,
            y: KLineConfig.shared.crandleInsets.top,
            width: chartView.bounds.size.width - KLineConfig.shared.crandleInsets.left - KLineConfig.shared.crandleInsets.right,
            height: KLineConfig.shared.mainCanvasHeight - KLineConfig.shared.crandleInsets.top - KLineConfig.shared.crandleInsets.bottom
        )
        return candleFrame
    }
    
    func gestureManager(_ gestureManager: KLineTapLongGestureManager, didSelectData data: KLineModel, at point: CGPoint) {
        // 记录选中的K线数据并更新主图技术指标显示
        selectedKLineModel = data
        
        // 设置十字线状态
        shouldShowCrossLine = true
        crossLinePoint = point
        
        // 显示详情视图
        showDetailView(for: data, at: point)
        
        drawUI()
        
        print("显示十字线和详情视图，选中K线数据: 时间=\(data.timestamp), 收盘价=\(data.close)")
    }
    
    func gestureManagerDidCancelSelection(_ gestureManager: KLineTapLongGestureManager) {
        // 设置十字线状态为隐藏
        shouldShowCrossLine = false
        crossLinePoint = .zero
        
        // 隐藏详情视图
        hideDetailView()
        
        drawUI()
        
        print("隐藏十字线和详情视图")
    }
}
