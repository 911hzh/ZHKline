//
//  KlinePeriodView.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import UIKit

/// K线周期选择视图
class KlinePeriodView: UIView {
    
    // MARK: - 属性
    
    /// 选中回调闭包
    var onPeriodSelected: ((KLinePeriod) -> Void)?
    
    /// 设置按钮点击回调
    var onSettingsButtonTapped: (() -> Void)?
    
    /// 放大按钮点击回调
    var onZoomButtonTapped: (() -> Void)?
    
    /// 更多按钮点击回调
    var onMoreButtonTapped: (() -> Void)?
    
    /// 当前选中的周期
    private var selectedPeriod: KLinePeriod = .min15 {
        didSet {
            updateSelectedState()
            onPeriodSelected?(selectedPeriod)
        }
    }
    
    /// 所有周期按钮数组
    private var periodButtons: [UIButton] = []
    
    /// 主容器视图
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
//        view.layer.cornerRadius = 8
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 1)
//        view.layer.shadowOpacity = 0.1
//        view.layer.shadowRadius = 2
        return view
    }()
    
    /// 左侧周期选择容器
    private let periodContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    /// 周期选择堆栈视图
    private let periodStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    /// 右侧控制按钮容器
    private let controlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    /// 更多按钮
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("更多", for: .normal)
        button.setTitleColor(UIColor.systemGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    /// 下拉箭头图标
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        // 使用系统的下拉箭头图标
        if let arrowImage = UIImage(systemName: "chevron.down") {
            imageView.image = arrowImage
        }
        imageView.tintColor = UIColor.systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 设置按钮
    private let settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        if let settingsImage = UIImage(systemName: "gearshape") {
            button.setImage(settingsImage, for: .normal)
        }
        button.tintColor = UIColor.systemGray
        return button
    }()
    
    /// 放大按钮
    private let zoomButton: UIButton = {
        let button = UIButton(type: .custom)
        if let zoomImage = UIImage(systemName: "magnifyingglass") {
            button.setImage(zoomImage, for: .normal)
        }
        button.tintColor = UIColor.systemGray
        return button
    }()
    
    /// 默认高度
    private let defaultHeight: CGFloat = 36
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    init(frame: CGRect, selectedPeriod: KLinePeriod, onPeriodSelected: ((KLinePeriod) -> Void)?) {
        super.init(frame: frame)
        self.selectedPeriod = selectedPeriod
        self.onPeriodSelected = onPeriodSelected
        setupUI()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // 添加主容器
        addSubview(containerView)
        
        // 添加左侧周期选择容器
        containerView.addSubview(periodContainerView)
        periodContainerView.addSubview(periodStackView)
        
        // 添加右侧控制按钮容器
        containerView.addSubview(controlContainerView)
        
        // 添加控制按钮
        setupControlButtons()
        
        // 创建周期按钮
        createPeriodButtons()
        
        // 设置按钮事件
        setupButtonActions()
        
        // 设置初始选中状态
        updateSelectedState()
    }
    
    private func setupControlButtons() {
        // 添加更多按钮和箭头
        controlContainerView.addSubview(moreButton)
        controlContainerView.addSubview(arrowImageView)
        
        // 添加设置按钮
        controlContainerView.addSubview(settingsButton)
        
        // 添加放大按钮
        controlContainerView.addSubview(zoomButton)
    }
    
    private func setupButtonActions() {
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        zoomButton.addTarget(self, action: #selector(zoomButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置容器视图frame
        containerView.frame = bounds
        
        // 计算左侧周期选择区域的宽度（总宽度的60%）
        let totalWidth = bounds.width
        let periodWidth = totalWidth * 0.6
        let controlWidth = totalWidth * 0.4
        
        // 设置左侧周期选择容器
        periodContainerView.frame = CGRect(x: 0, y: 0, width: periodWidth, height: bounds.height)
        periodStackView.frame = periodContainerView.bounds
        
        // 设置右侧控制按钮容器
        controlContainerView.frame = CGRect(x: periodWidth, y: 0, width: controlWidth, height: bounds.height)
        
        // 布局右侧控制按钮
        layoutControlButtons()
    }
    
    private func layoutControlButtons() {
        let containerWidth = controlContainerView.bounds.width
        let containerHeight = controlContainerView.bounds.height
        
        // 简化布局：均匀分布三个元素
        let elementWidth = containerWidth / 3
        
        // 更多按钮和箭头组合
        let moreAreaX: CGFloat = 0
        moreButton.frame = CGRect(x: moreAreaX + 8, y: 0, width: 28, height: containerHeight)
        arrowImageView.frame = CGRect(x: moreAreaX + 32, y: (containerHeight - 10) / 2, width: 10, height: 10)
        
        // 设置按钮
        let settingsX = elementWidth
        settingsButton.frame = CGRect(x: settingsX + (elementWidth - 20) / 2, y: (containerHeight - 20) / 2, width: 20, height: 20)
        
        // 放大按钮
        let zoomX = elementWidth * 2
        zoomButton.frame = CGRect(x: zoomX + (elementWidth - 20) / 2, y: (containerHeight - 20) / 2, width: 20, height: 20)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: defaultHeight)
    }
    
    /// 创建周期按钮
    private func createPeriodButtons() {
        // 清空现有按钮
        periodButtons.forEach { $0.removeFromSuperview() }
        periodButtons.removeAll()
        
        // 为每个周期创建按钮
        for (index, period) in KLinePeriod.allCases.enumerated() {
            let button = createPeriodButton(for: period, at: index)
            periodButtons.append(button)
            periodStackView.addArrangedSubview(button)
        }
    }
    
    /// 创建单个周期按钮
    /// - Parameters:
    ///   - period: 周期枚举
    ///   - index: 索引位置
    /// - Returns: 配置好的按钮
    private func createPeriodButton(for period: KLinePeriod, at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        
        // 设置按钮文本
        button.setTitle(getPeriodDisplayText(period), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        
        // 设置按钮样式
        button.backgroundColor = UIColor.clear
        
        // 简化设计：去掉所有边框和圆角
        
        // 绑定点击事件
        button.addTarget(self, action: #selector(periodButtonTapped(_:)), for: .touchUpInside)
        button.tag = index
        
        return button
    }
    
    /// 获取周期显示文本
    /// - Parameter period: 周期枚举
    /// - Returns: 显示文本
    private func getPeriodDisplayText(_ period: KLinePeriod) -> String {
        switch period {
        case .min15:
            return "15分"
        case .min60:
            return "1时"
        case .hour4:
            return "4时"
        case .day1:
            return "1日"
        case .mon1:
            return "1周"
        }
    }
    
    // MARK: - 事件处理
    
    /// 周期按钮点击事件
    /// - Parameter sender: 被点击的按钮
    @objc private func periodButtonTapped(_ sender: UIButton) {
        let selectedIndex = sender.tag
        guard selectedIndex < KLinePeriod.allCases.count else { return }
        
        let period = Array(KLinePeriod.allCases)[selectedIndex]
        selectedPeriod = period
    }
    
    /// 更多按钮点击事件
    @objc private func moreButtonTapped() {
        onMoreButtonTapped?()
    }
    
    /// 设置按钮点击事件
    @objc private func settingsButtonTapped() {
        onSettingsButtonTapped?()
    }
    
    /// 放大按钮点击事件
    @objc private func zoomButtonTapped() {
        onZoomButtonTapped?()
    }
    
    /// 更新选中状态
    private func updateSelectedState() {
        for (index, button) in periodButtons.enumerated() {
            let period = Array(KLinePeriod.allCases)[index]
            let isSelected = period == selectedPeriod
            
            button.isSelected = isSelected
            
            if isSelected {
                // 选中状态：深色文字，无背景
                button.backgroundColor = UIColor.clear
                button.setTitleColor(UIColor.label, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            } else {
                // 未选中状态：灰色文字，无背景
                button.backgroundColor = UIColor.clear
                button.setTitleColor(UIColor.systemGray, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            }
        }
    }
    
    // MARK: - 公开方法
    
    /// 设置选中的周期
    /// - Parameter period: 要选中的周期
    func setSelectedPeriod(_ period: KLinePeriod) {
        selectedPeriod = period
    }
    
    /// 获取当前选中的周期
    /// - Returns: 当前选中的周期
    func getSelectedPeriod() -> KLinePeriod {
        return selectedPeriod
    }
    deinit {
        print("deinit \(self)")
    }
}
