//
//  ChartViewController.swift
//  ZHKLine
//
//  Created by huang on 2025/9/8.
//

import Foundation
import UIKit

class ChartViewController: UIViewController {
    private var datas: [KLineModel] = []
    private var selectedPeriod: KLinePeriod = KLinePeriod.min15
    private lazy var periodSelectView: KlinePeriodView = {
        let view = KlinePeriodView(frame: CGRect(x: 0, y: 90, width: view.bounds.size.width, height: 30), selectedPeriod: selectedPeriod) {[weak self] selectedPeriod in
            guard let self = self else { return }
            self.selectedPeriod = selectedPeriod
            self.kLineView.clearDatas()
            self.getData()
        }
        return view
    }()
    private lazy var kLineView: KLineView = {
        let view = KLineView(frame: CGRect(x: 0, y: 120, width: self.view.bounds.width, height: KLineConfig.shared.getAllHeight(indicatorTypes: [])))
        view.heightChanged = {[weak self] height in
            guard let self = self else { return }
            var oldFrame = self.kLineView.frame
            oldFrame.size.height = height
            self.kLineView.frame = oldFrame
            
            var scaleButtonFrame = self.scaleButton.frame
            scaleButtonFrame.origin.y = kLineView.frame.maxY + 20
            self.scaleButton.frame = scaleButtonFrame
            
        }
        return view
    }()
    private lazy var scaleButton: UIButton = {
        let view = UIButton()
        view.setTitle("scale * 1.2", for: UIControl.State.normal)
        view.addTarget(self, action: #selector(tapScaleButton), for: UIControl.Event.touchUpInside)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关闭", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        return button
    }()
    
    @objc private func tapScaleButton() {
        KLineConfig.scale *= 1.2
        kLineView.setupDatas(datas: self.datas)
    }
    
    @objc private func closeViewController() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
        getData()
    }
    
    private func setupUI() {
        view.addSubview(periodSelectView)
        view.addSubview(kLineView)
        view.addSubview(scaleButton)
        view.addSubview(closeButton)
        
        // 设置scaleButton的frame
        scaleButton.frame = CGRect(x: (view.bounds.width - 120) / 2, y: kLineView.frame.maxY + 20, width: 120, height: 40)
        
        // 设置closeButton的frame (在右上角)
        closeButton.frame = CGRect(x: view.bounds.width - 80, y: 40, width: 60, height: 30)
    }
    
    func getData() {
        Task {
            let apiDatas = try? await  KlineApi.shared.getBatchKLineData(symbols: ["btcusdt"], period: self.selectedPeriod,size: 2000)
            await MainActor.run {[weak self] in
                guard let self = self else { return }
                // 获取原始数据并计算技术指标
                if let rawData = apiDatas?["btcusdt"] {
                    // 使用新的扩展方法，包含技术指标计算
                    self.datas = DataUtil.toKLineModelsWithIndicators(datas: rawData, selectedPeriod: self.selectedPeriod)
                    print("request datas: \(self.datas.count)")
                    
                    kLineView.setupDatas(datas: self.datas)
                }
            }
        }
    }
}
