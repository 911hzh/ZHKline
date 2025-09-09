//
//  KLineTapLongGestureManager.swift
//  ZHKLine
//
//  Created by huang on 2025/12/28.
//

import Foundation
import UIKit

/// K线点击长按手势管理器代理协议
protocol KLineTapLongGestureManagerDelegate: AnyObject {
    /// 获取当前的数据数组
    func klineDataModels(for gestureManager: KLineTapLongGestureManager) -> [KLineModel]
    
    /// 获取当前的scrollView
    func scrollView(for gestureManager: KLineTapLongGestureManager) -> UIScrollView
    
    /// 获取蜡烛图层的frame（用于点击区域判断）
    func candleLayerFrame(for gestureManager: KLineTapLongGestureManager) -> CGRect
    
    /// 手势管理器选中了数据
    func gestureManager(_ gestureManager: KLineTapLongGestureManager, didSelectData data: KLineModel, at point: CGPoint)
    
    /// 手势管理器取消了选择
    func gestureManagerDidCancelSelection(_ gestureManager: KLineTapLongGestureManager)
}

/// K线点击长按手势管理器 - 精简版，专注于点击检测和十字线显示
class KLineTapLongGestureManager: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: KLineTapLongGestureManagerDelegate?
    
    /// 点击手势识别器
    private var tapGesture: UITapGestureRecognizer!
    
    /// 长按手势识别器
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// 当前选中的数据索引
    private var selectedIndex: Int = -1
    
    /// 是否正在长按模式
    private var isLongPressMode: Bool = false
    
    // MARK: - Lifecycle
    
    init(delegate: KLineTapLongGestureManagerDelegate) {
        self.delegate = delegate
        super.init()
        setupGestures()
    }
    
    // MARK: - Public Methods
    
    /// 将手势添加到指定视图
    func addGestureToView(_ view: UIView) {
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(longPressGesture)
    }
    
    /// 移除手势
    func removeGestureFromView(_ view: UIView) {
        view.removeGestureRecognizer(tapGesture)
        view.removeGestureRecognizer(longPressGesture)
    }
    
    /// 重置选择状态
    func resetSelection() {
        selectedIndex = -1
        isLongPressMode = false
        cancelSelection()
    }
    
    // MARK: - Private Methods
    
    /// 设置手势识别器
    private func setupGestures() {
        // 点击手势
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        
        // 长按手势
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        
        // 设置手势优先级，长按手势优先级高于点击手势
        tapGesture.require(toFail: longPressGesture)
    }
    
    /// 处理点击手势
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        handleGestureAtLocation(location)
    }
    
    /// 处理长按手势
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        let location = gesture.location(in: gesture.view)
        let scrollView = delegate.scrollView(for: self)
        
        switch gesture.state {
        case .began:
            isLongPressMode = true
            scrollView.isScrollEnabled = false
            handleGestureAtLocation(location)
            
        case .changed:
            handleGestureAtLocation(location)
            
        case .ended, .cancelled:
            isLongPressMode = false
            scrollView.isScrollEnabled = true
            
        default:
            break
        }
    }
    
    /// 统一处理手势位置
    private func handleGestureAtLocation(_ location: CGPoint) {
        guard let delegate = delegate else { return }
        
        // 检查点击是否在蜡烛图区域内
        let candleFrame = delegate.candleLayerFrame(for: self)
        guard candleFrame.contains(location) else {
            cancelSelection()
            return
        }
        
        // 计算对应的数据
        let scrollView = delegate.scrollView(for: self)
        let actualX = location.x + scrollView.contentOffset.x
        let datas = delegate.klineDataModels(for: self)
        let index = findDataModelIndex(at: actualX, datas: datas)
        
        if index >= 0 && index < datas.count {
            selectedIndex = index
            let selectedData = datas[index]
            
            // 通过代理通知选中
            delegate.gestureManager(self, didSelectData: selectedData, at: location)
        } else {
            cancelSelection()
        }
    }
    
    /// 根据X坐标查找对应的数据模型索引
    private func findDataModelIndex(at absoluteX: CGFloat, datas: [KLineModel]) -> Int {
        let itemWidth = KLineConfig.shared.candleWidth + KLineConfig.shared.candleSpace
        let adjustedX = absoluteX - KLineConfig.shared.crandleInsets.left
        let index = Int(adjustedX / itemWidth)
        return max(0, min(datas.count - 1, index))
    }
    
    /// 取消选择
    private func cancelSelection() {
        selectedIndex = -1
        delegate?.gestureManagerDidCancelSelection(self)
    }
    deinit {
        print("deinit \(self)")
    }
}

// MARK: - UIGestureRecognizerDelegate

extension KLineTapLongGestureManager: UIGestureRecognizerDelegate {
    
    /// 允许多个手势同时识别
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 在长按模式下，阻止其他手势
        if isLongPressMode && gestureRecognizer == longPressGesture {
            return false
        }
        return true
    }
    
    /// 控制手势是否应该开始
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
