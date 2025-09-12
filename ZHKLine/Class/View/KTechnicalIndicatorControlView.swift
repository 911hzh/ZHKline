//
//  KTechnicalIndicatorControlView.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import UIKit

/// 技术指标选择控制视图委托协议
protocol KTechnicalIndicatorControlViewDelegate: AnyObject {
    func indicatorControlView(_ controlView: KTechnicalIndicatorControlView, didUpdateSelection types: [KLineTechnicalIndicatorType])
}

/// 技术指标选择控制视图
class KTechnicalIndicatorControlView: UIView {
    
    weak var delegate: KTechnicalIndicatorControlViewDelegate?
    
    /// 当前选中的指标类型集合（支持多选）
    private var selectedIndicatorTypes: [KLineTechnicalIndicatorType] = []
    
    /// 指标按钮数组
    private var indicatorButtons: [UIButton] = []
    
    /// 主图指标类型和标题映射
    private let mainIndicatorTitles: [(KLineTechnicalIndicatorType, String)] = [
        (.ma, "MA"),
        (.ema, "EMA"),
        (.boll, "BOLL")
    ]
    
    /// 副图指标类型和标题映射
    private let secondIndicatorTitles: [(KLineTechnicalIndicatorType, String)] = [
        (.volume, "VOL"),
        (.macd, "MACD"),
        (.kdj, "KDJ"),
        (.rsi, "RSI"),
        (.wr, "WR")
    ]
    
    /// 分割线视图
    private var separatorView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 1, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if indicatorButtons.isEmpty {
            setupButtons()
        }
    }
    
    private func setupButtons() {
        let totalCount = mainIndicatorTitles.count + secondIndicatorTitles.count
        let separatorWidth: CGFloat = 1.0
        let availableWidth = bounds.width - separatorWidth
        let buttonWidth = availableWidth / CGFloat(totalCount)
        
        var currentX: CGFloat = 0
        var buttonIndex = 0
        
        // 创建主图指标按钮
        for (type, title) in mainIndicatorTitles {
            let button = createIndicatorButton(title: title, type: type)
            button.tag = buttonIndex
            button.frame = CGRect(x: currentX, y: 0, width: buttonWidth, height: bounds.height)
            addSubview(button)
            indicatorButtons.append(button)
            currentX += buttonWidth
            buttonIndex += 1
        }
        
//        // 创建分割线（上下各留10像素间距）
        let separatorMargin: CGFloat = 10.0
        let separatorViewNew = UIView(frame: CGRect(x: currentX, y: separatorMargin, width: separatorWidth, height: bounds.height - separatorMargin * 2))
        separatorViewNew.backgroundColor = UIColor.lightGray
        separatorView = separatorViewNew
        addSubview(separatorViewNew)
        self.separatorView = separatorViewNew
        currentX += separatorWidth
//        
//        // 创建副图指标按钮
        for (type, title) in secondIndicatorTitles {
            let button = createIndicatorButton(title: title, type: type)
            button.tag = buttonIndex
            button.frame = CGRect(x: currentX+separatorWidth, y: 0, width: buttonWidth, height: bounds.height)
            addSubview(button)
            indicatorButtons.append(button)
            currentX += buttonWidth
            buttonIndex += 1
        }
//        
//        // 默认选中第一个
//        updateButtonSelection()
    }
    
    private func createIndicatorButton(title: String, type: KLineTechnicalIndicatorType) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular) // 字体改小，改为regular
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.black, for: .selected)
        button.layer.cornerRadius = 0
        button.addTarget(self, action: #selector(indicatorButtonTapped(_:)), for: .touchUpInside)
        
        // 存储指标类型
        button.accessibilityIdentifier = "\(type)"
        
        return button
    }
    
    @objc private func indicatorButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let allIndicatorTitles = mainIndicatorTitles + secondIndicatorTitles
        guard index < allIndicatorTitles.count else { return }
        
        let (type, _) = allIndicatorTitles[index]
        
        // 切换选择状态（支持多选）
        if selectedIndicatorTypes.contains(type) {
            selectedIndicatorTypes = selectedIndicatorTypes.filter({$0 != type})
        } else {
            selectedIndicatorTypes.append(type)
        }
        
        updateButtonSelection()
        
        // 通知委托
        delegate?.indicatorControlView(self, didUpdateSelection: selectedIndicatorTypes)
    }
    
    private func updateButtonSelection() {
        let allIndicatorTitles = mainIndicatorTitles + secondIndicatorTitles
        for (index, button) in indicatorButtons.enumerated() {
            guard index < allIndicatorTitles.count else { continue }
            let (type, _) = allIndicatorTitles[index]
            let isSelected = selectedIndicatorTypes.contains(type)
            
            button.isSelected = isSelected
            // 选择状态：不改变背景色，只改变文字颜色
            button.backgroundColor = UIColor.white
            button.setTitleColor(isSelected ? UIColor.black : UIColor.darkGray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: isSelected ? .medium : .regular) // 字体改小，选中状态使用medium
        }
    }
    deinit {
        print("deinit \(self)")
    }
}
