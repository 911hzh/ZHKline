//
//  KLineDetailView.swift
//  ZHKLine
//
//  Created by huang on 2025/12/28.
//

import Foundation
import UIKit

/// K线详细信息显示视图
class KLineDetailView: UIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let timeLabel = UILabel()
    private let openLabel = UILabel()
    private let highLabel = UILabel()
    private let lowLabel = UILabel()
    private let closeLabel = UILabel()
    private let changeAmountLabel = UILabel()
    private let changeRateLabel = UILabel()
    private let volumeLabel = UILabel()
    
    // MARK: - Properties
    
    private var currentData: KLineModel?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 使用交叉线的颜色作为背景色
        backgroundColor = KLineConfig.shared.crossLineColor.withAlphaComponent(0.9)
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = KLineConfig.shared.crossLineColor.cgColor
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        // 配置StackView
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 1  // 整体间距更小
        
        let labels = [timeLabel, openLabel, highLabel, lowLabel, closeLabel, changeAmountLabel, changeRateLabel, volumeLabel]
        
        labels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 8)
            label.textColor = .black  // 所有字体都改为黑色
            stackView.addArrangedSubview(label)
        }
        
        // 设置timeLabel固定高度，避免高度过大
        timeLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        // 设置timeLabel和openLabel之间的间距最小
        stackView.setCustomSpacing(0, after: timeLabel)  // timeLabel后面间距设为0
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // containerView约束
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            
            // stackView约束
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    /// 更新显示数据
    func updateData(_ data: KLineModel) {
        currentData = data
        
        // 格式化时间为新加坡时间日期格式
        let date = Date(timeIntervalSince1970: TimeInterval(data.timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Singapore")  // 使用新加坡时区
        timeLabel.text = formatter.string(from: date)
        
        // 开盘价
        openLabel.text = "开    \(String(format: "%.2f", data.open))"
        
        // 最高价
        highLabel.text = "高    \(String(format: "%.2f", data.high))"
        
        // 最低价
        lowLabel.text = "低    \(String(format: "%.2f", data.low))"
        
        // 收盘价
        closeLabel.text = "收    \(String(format: "%.2f", data.close))"
        
        // 涨跌额
        let changeAmount = data.changeAmount
        let changeAmountText = changeAmount >= 0 ? "+\(String(format: "%.2f", changeAmount))" : "\(String(format: "%.2f", changeAmount))"
        changeAmountLabel.text = "涨跌额    \(changeAmountText)"
        changeAmountLabel.textColor = changeAmount >= 0 ? .systemGreen : .systemRed
        
        // 涨跌幅
        let changeRate = data.changeRate * 100
        let changeRateText = changeRate >= 0 ? "+\(String(format: "%.2f", changeRate))%" : "\(String(format: "%.2f", changeRate))%"
        changeRateLabel.text = "涨跌幅    \(changeRateText)"
        changeRateLabel.textColor = changeRate >= 0 ? .systemGreen : .systemRed
        
        // 成交量
        volumeLabel.text = "成交量    \(String(format: "%.2f", data.volume))"
    }
    
    /// 显示在指定位置
    func show(at point: CGPoint, in containerView: UIView, preferRight: Bool = true) {
        // 直接添加到containerView（现在是KLineView）
        containerView.addSubview(self)
        
        // 动态计算实际需要的尺寸
        let calculatedSize = calculateRequiredSize()
        let margin: CGFloat = 16  // 距离边缘的最小间距
        
        var finalX: CGFloat
        let finalY: CGFloat = margin  // 固定在顶部位置
        
        if preferRight {
            // 固定显示在右边
            finalX = containerView.bounds.width - calculatedSize.width - margin
        } else {
            // 固定显示在左边
            finalX = margin
        }
        
        frame = CGRect(x: finalX, y: finalY, width: calculatedSize.width, height: calculatedSize.height)
        
        // 添加显示动画
        alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    /// 计算实际需要的尺寸
    private func calculateRequiredSize() -> CGSize {
        // 强制布局以获取准确的尺寸
        setNeedsLayout()
        layoutIfNeeded()
        
        // 获取stackView的实际内容尺寸
        let stackViewSize = stackView.systemLayoutSizeFitting(
            CGSize(width: UIView.layoutFittingCompressedSize.width, 
                   height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        // 加上容器的内边距 (左右各6pt，上下各3pt)
        let containerPadding: CGFloat = 6 * 2  // 左右边距
        let verticalPadding: CGFloat = 3 * 2   // 上下边距
        
        let requiredWidth = stackViewSize.width + containerPadding
        let requiredHeight = stackViewSize.height + verticalPadding
        
        // 设置最小尺寸，防止过小
        let minWidth: CGFloat = 80
        let minHeight: CGFloat = 60
        
        let finalWidth = max(requiredWidth, minWidth)
        let finalHeight = max(requiredHeight, minHeight)
        
        print("📏 动态尺寸计算 - StackView: \(stackViewSize), 最终: \(finalWidth)x\(finalHeight)")
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
    
    /// 隐藏视图
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    deinit {
        print("deinit \(self)")
    }
}
