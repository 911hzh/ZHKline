//
//  KLineScaleGestureManager.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import UIKit

/// K线缩放手势管理器的代理协议
protocol KLineScaleGestureManagerDelegate: AnyObject {
    /// 获取当前的数据数组
    /// - Parameter manager: 缩放手势管理器
    /// - Returns: K线数据数组
    func dataModels(for manager: KLineScaleGestureManager) -> [KLineModel]
    
    /// 获取当前的scrollView
    /// - Parameter manager: 缩放手势管理器
    /// - Returns: 滚动视图
    func scrollView(for manager: KLineScaleGestureManager) -> UIScrollView
    
//    /// 缩放手势即将开始
//    /// - Parameter manager: 缩放手势管理器
//    func scaleGestureManagerWillBeginScaling(_ manager: KLineScaleGestureManager)
    
//    /// 缩放手势进行中
//    /// - Parameters:
//    ///   - manager: 缩放手势管理器
//    ///   - scale: 新的缩放比例
//    func scaleGestureManager(_ manager: KLineScaleGestureManager, didChangeScale scale: CGFloat)
    
    /// 缩放手势已结束
    /// - Parameter manager: 缩放手势管理器
//    func scaleGestureManagerDidEndScaling(_ manager: KLineScaleGestureManager)
    
    /// 请求更新UI
    /// - Parameter manager: 缩放手势管理器
    func scaleGestureManagerShouldUpdateUI(_ manager: KLineScaleGestureManager)
}

/// K线缩放手势管理器
class KLineScaleGestureManager: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: KLineScaleGestureManagerDelegate?
    
    /// 缩放手势识别器
    private var pinchGesture: UIPinchGestureRecognizer!
    
    /// 缩放相关状态
    private var gestureStartScale: CGFloat = 1.0
    private var gestureStartCenterX: CGFloat = 0.0
    private var centerDataModelIndex: Int = 0
    private var centerDataModel: KLineModel?
    private var gestureStartContentOffset: CGFloat = 0.0
    private var isScaling: Bool = false
    
    /// 缩放范围限制
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 3.0
    
    // MARK: - Lifecycle
    
    init(delegate: KLineScaleGestureManagerDelegate) {
        self.delegate = delegate
        super.init()
        setupPinchGesture()
    }
    
    // MARK: - Public Methods
    
    /// 将手势添加到指定视图
    func addGestureToView(_ view: UIView) {
        view.addGestureRecognizer(pinchGesture)
    }
    
    /// 移除手势
    func removeGestureFromView(_ view: UIView) {
        view.removeGestureRecognizer(pinchGesture)
    }
    
    /// 获取当前是否正在缩放
    var isCurrentlyScaling: Bool {
        return isScaling
    }
    
    // MARK: - Private Methods
    
    /// 设置缩放手势识别器
    private func setupPinchGesture() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
    }
    
    /// 处理缩放手势
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            handlePinchBegan(gesture)
        case .changed:
            handlePinchChanged(gesture)
        case .ended, .cancelled:
            handlePinchEnded(gesture)
        default:
            break
        }
    }
    
    /// 缩放开始时的处理
    private func handlePinchBegan(_ gesture: UIPinchGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        // 设置缩放状态
        isScaling = true
        
        // 通知代理缩放开始
//        delegate.scaleGestureManagerWillBeginScaling(self)
        
        // 记录开始时的缩放比例
        gestureStartScale = KLineConfig.scale
        
        // 获取手势在视图中的位置
        let gestureLocationInView = gesture.location(in: gesture.view)
        gestureStartCenterX = gestureLocationInView.x
        
        // 记录开始时的contentOffset
        let scrollView = delegate.scrollView(for: self)
        gestureStartContentOffset = scrollView.contentOffset.x
        
        // 查找手势中心点对应的数据模型
        let datas = delegate.dataModels(for: self)
        centerDataModelIndex = findDataModelIndex(at: gestureStartCenterX + gestureStartContentOffset, datas: datas)
        if centerDataModelIndex >= 0 && centerDataModelIndex < datas.count {
            centerDataModel = datas[centerDataModelIndex]
        }
        
        print("缩放开始 - 手势在视图中的X: \(gestureStartCenterX), 数据索引: \(centerDataModelIndex), contentOffset: \(gestureStartContentOffset)")
    }
    
    /// 缩放进行中的处理
    private func handlePinchChanged(_ gesture: UIPinchGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        // 计算新的缩放比例
        let newScale = gestureStartScale * gesture.scale
        
        // 限制缩放范围
        let clampedScale = max(minScale, min(maxScale, newScale))
        
        // 应用新的缩放比例
        KLineConfig.scale = clampedScale
        
        // 通知代理缩放比例改变
//        delegate.scaleGestureManager(self, didChangeScale: clampedScale)
        
        // 重新计算内容大小和位置
        updateScrollViewContentSize()
        
        // 调整contentOffset以保持中心点不变
        adjustContentOffsetForCenter()
        
        // 更新UI
        delegate.scaleGestureManagerShouldUpdateUI(self)
        
        print("缩放中 - 新缩放比例: \(clampedScale), 手势scale: \(gesture.scale)")
    }
    
    /// 缩放结束时的处理
    private func handlePinchEnded(_ gesture: UIPinchGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        // 结束缩放状态
        isScaling = false
        
        // 重置手势状态
        gesture.scale = 1.0
        centerDataModel = nil
        
//        // 通知代理缩放结束
//        delegate.scaleGestureManagerDidEndScaling(self)
        
        // 最终更新UI
        delegate.scaleGestureManagerShouldUpdateUI(self)
        
        print("缩放结束")
    }
    
    /// 根据X坐标查找对应的数据模型索引
    private func findDataModelIndex(at absoluteX: CGFloat, datas: [KLineModel]) -> Int {
        let itemWidth = KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace
        let adjustedX = absoluteX - KLineConfig.shared.crandleInsets.left
        let index = Int(adjustedX / itemWidth)
        return max(0, min(datas.count - 1, index))
    }
    
    /// 更新scrollView的内容大小
    private func updateScrollViewContentSize() {
        guard let delegate = delegate else { return }
        
        let datas = delegate.dataModels(for: self)
        let scrollView = delegate.scrollView(for: self)
        
        
        let contentWidth = (KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace) * CGFloat(datas.count) + KLineConfig.shared.crandleInsets.left +
        KLineConfig.shared.crandleInsets.right + KLineConfig.shared.crossLineWidth * 2
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.bounds.size.height)
    }
    
    /// 调整contentOffset以保持中心点数据模型的位置不变
    private func adjustContentOffsetForCenter() {
        guard let delegate = delegate else { return }
        guard centerDataModelIndex >= 0 else { return }
        
        let datas = delegate.dataModels(for: self)
        guard centerDataModelIndex < datas.count else { return }
        
        let scrollView = delegate.scrollView(for: self)
        
        // 计算中心数据模型在新缩放比例下的绝对X位置
        let itemWidth = KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace
        let newAbsoluteCenterX = CGFloat(centerDataModelIndex) * itemWidth + KLineConfig.shared.crandleInsets.left + KLineConfig.shared.candleWidth/2
        
        // 计算需要的contentOffset以保持手势点在视图中的位置不变
        let targetContentOffsetX = newAbsoluteCenterX - gestureStartCenterX
        
        // 应用边界限制
        let maxContentOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        let minContentOffsetX: CGFloat = 0
        let finalContentOffsetX = max(minContentOffsetX, min(maxContentOffsetX, targetContentOffsetX))
        
        // 设置新的contentOffset
        scrollView.contentOffset.x = finalContentOffsetX
        
        print("调整contentOffset - 中心数据索引: \(centerDataModelIndex)")
        print("  新绝对位置: \(newAbsoluteCenterX), 手势视图位置: \(gestureStartCenterX)")
        print("  目标offset: \(targetContentOffsetX), 最终offset: \(finalContentOffsetX), 最大offset: \(maxContentOffsetX)")
    }
    deinit {
        print("deinit \(self)")
    }
}

