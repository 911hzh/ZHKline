//
//  KMainIndicatorTextView.swift
//  ZHKLine
//
//  Created by huang on 2025/12/28.
//

import Foundation
import UIKit

/// 主图技术指标文本显示视图 - 使用UIStackView的优化实现
class KMainIndicatorTextView: UIView {
    
    // MARK: - 配置属性
    
    /// 标签样式配置
    struct LabelStyle {
        let topMargin: CGFloat
        let leftMargin: CGFloat
        let lineSpacing: CGFloat
        let labelSpacing: CGFloat
        let fontSize: CGFloat
        
        static let `default` = LabelStyle(
            topMargin: 5,
            leftMargin: 10,
            lineSpacing: 2,
            labelSpacing: 8,
            fontSize: 9
        )
    }
    
    // MARK: - 私有属性
    
    private let labelStyle: LabelStyle = .default
    
    // 主容器 StackView - 垂直布局，每行一个指标类型
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 2 // 行间距
        return stack
    }()
    
    // 预创建的指标行容器
    private let maStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    private let emaStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    private let bollStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    // 预创建的标签，避免重复创建和销毁
    private let ma5Label = UILabel()
    private let ma10Label = UILabel()
    private let ma30Label = UILabel()
    
    private let ema5Label = UILabel()
    private let ema10Label = UILabel()
    private let ema30Label = UILabel()
    
    private let bollUpperLabel = UILabel()
    private let bollMiddleLabel = UILabel()
    private let bollLowerLabel = UILabel()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - 设置
    
    private func setupView() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        
        // 添加主StackView
        addSubview(mainStackView)
        
        // 设置约束
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: labelStyle.topMargin),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: labelStyle.leftMargin),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -labelStyle.leftMargin),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -labelStyle.topMargin)
        ])
        
        // 添加指标行到主StackView
        mainStackView.addArrangedSubview(maStackView)
        mainStackView.addArrangedSubview(emaStackView)
        mainStackView.addArrangedSubview(bollStackView)
        
        // 设置标签并添加到对应的StackView
        setupLabels()
    }
    
    private func setupLabels() {
        let allLabels = [ma5Label, ma10Label, ma30Label, ema5Label, ema10Label, ema30Label, bollUpperLabel, bollMiddleLabel, bollLowerLabel]
        
        // 配置所有标签的通用属性
        allLabels.forEach { label in
            label.font = UIFont.systemFont(ofSize: labelStyle.fontSize)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
        }
        
        // 添加MA标签
        maStackView.addArrangedSubview(ma5Label)
        maStackView.addArrangedSubview(ma10Label)
        maStackView.addArrangedSubview(ma30Label)
        
        // 添加EMA标签
        emaStackView.addArrangedSubview(ema5Label)
        emaStackView.addArrangedSubview(ema10Label)
        emaStackView.addArrangedSubview(ema30Label)
        
        // 添加BOLL标签
        bollStackView.addArrangedSubview(bollUpperLabel)
        bollStackView.addArrangedSubview(bollMiddleLabel)
        bollStackView.addArrangedSubview(bollLowerLabel)
    }
    
    // MARK: - 公共方法
    
    /// 简化的配置方法 - 只需要三个核心参数
    /// - Parameters:
    ///   - selectedKLineModel: 当前选中的K线数据
    ///   - config: K线配置对象
    ///   - selection: 主图技术指标选择
    func configure(
        selectedKLineModel: KLineModel?,
        config: KLineConfig,
        selection: [KLineTechnicalIndicatorType]
    ) {
        // 更新MA指标
        updateMAIndicators(selectedKLineModel: selectedKLineModel, config: config, isVisible: selection.contains(.ma))
        
        // 更新EMA指标
        updateEMAIndicators(selectedKLineModel: selectedKLineModel, config: config, isVisible: selection.contains(.ema))
        
        // 更新BOLL指标
        updateBOLLIndicators(selectedKLineModel: selectedKLineModel, config: config, isVisible: selection.contains(.boll))
    }
    
    // MARK: - 私有方法 - 指标更新
    
    /// 更新MA指标
    private func updateMAIndicators(selectedKLineModel: KLineModel?, config: KLineConfig, isVisible: Bool) {
        maStackView.isHidden = !isVisible
        
        guard isVisible, let model = selectedKLineModel, let indicators = model.KLineTechnicalIndicatorsModel else {
            return
        }
        
        // 更新MA5
        if let ma5 = indicators.ma5 {
            ma5Label.text = "MA5:\(String(format: "%.2f", ma5))"
            ma5Label.textColor = config.ma5Color
            ma5Label.isHidden = false
        } else {
            ma5Label.isHidden = true
        }
        
        // 更新MA10
        if let ma10 = indicators.ma10 {
            ma10Label.text = "MA10:\(String(format: "%.2f", ma10))"
            ma10Label.textColor = config.ma10Color
            ma10Label.isHidden = false
        } else {
            ma10Label.isHidden = true
        }
        
        // 更新MA30
        if let ma30 = indicators.ma30 {
            ma30Label.text = "MA30:\(String(format: "%.2f", ma30))"
            ma30Label.textColor = config.ma30Color
            ma30Label.isHidden = false
        } else {
            ma30Label.isHidden = true
        }
    }
    
    /// 更新EMA指标
    private func updateEMAIndicators(selectedKLineModel: KLineModel?, config: KLineConfig, isVisible: Bool) {
        emaStackView.isHidden = !isVisible
        
        guard isVisible, let model = selectedKLineModel, let indicators = model.KLineTechnicalIndicatorsModel else {
            return
        }
        
        // 更新EMA5
        if let ema5 = indicators.ema5 {
            ema5Label.text = "EMA5:\(String(format: "%.2f", ema5))"
            ema5Label.textColor = config.ema5Color
            ema5Label.isHidden = false
        } else {
            ema5Label.isHidden = true
        }
        
        // 更新EMA10
        if let ema10 = indicators.ema10 {
            ema10Label.text = "EMA10:\(String(format: "%.2f", ema10))"
            ema10Label.textColor = config.ema10Color
            ema10Label.isHidden = false
        } else {
            ema10Label.isHidden = true
        }
        
        // 更新EMA30
        if let ema30 = indicators.ema30 {
            ema30Label.text = "EMA30:\(String(format: "%.2f", ema30))"
            ema30Label.textColor = config.ema30Color
            ema30Label.isHidden = false
        } else {
            ema30Label.isHidden = true
        }
    }
    
    /// 更新BOLL指标
    private func updateBOLLIndicators(selectedKLineModel: KLineModel?, config: KLineConfig, isVisible: Bool) {
        bollStackView.isHidden = !isVisible
        
        guard isVisible, let model = selectedKLineModel, let indicators = model.KLineTechnicalIndicatorsModel else {
            return
        }
        
        // 更新BOLL上轨
        if let bollUpper = indicators.bollUpper {
            bollUpperLabel.text = "UPPER:\(String(format: "%.2f", bollUpper))"
            bollUpperLabel.textColor = config.bollUpperColor
            bollUpperLabel.isHidden = false
        } else {
            bollUpperLabel.isHidden = true
        }
        
        // 更新BOLL中轨
        if let bollMiddle = indicators.bollMiddle {
            bollMiddleLabel.text = "MB:\(String(format: "%.2f", bollMiddle))"
            bollMiddleLabel.textColor = config.bollMiddleColor
            bollMiddleLabel.isHidden = false
        } else {
            bollMiddleLabel.isHidden = true
        }
        
        // 更新BOLL下轨
        if let bollLower = indicators.bollLower {
            bollLowerLabel.text = "LOWER:\(String(format: "%.2f", bollLower))"
            bollLowerLabel.textColor = config.bollLowerColor
            bollLowerLabel.isHidden = false
        } else {
            bollLowerLabel.isHidden = true
        }
    }
    deinit {
        print("deinit \(self)")
    }
}
