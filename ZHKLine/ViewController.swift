//
//  ViewController.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var goToChartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Chart VC", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(goToChartViewController), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(goToChartButton)
        
        // 设置按钮的frame
        goToChartButton.frame = CGRect(x: (view.bounds.width - 200) / 2, y: 200, width: 200, height: 50)
    }
    
    @objc private func goToChartViewController() {
        let chartVC = ChartViewController()
        chartVC.modalPresentationStyle = .fullScreen
        present(chartVC, animated: true)
    }
}

