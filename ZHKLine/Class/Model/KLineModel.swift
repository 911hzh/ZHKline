//
//  KLineModel.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import CoreGraphics

/// K线数据模型
struct KLineModel {
    /// 原始K线数据（组合引用）
    let klineData: KLineData
    
    /// 选中的周期
    let selectedPeriod: KLinePeriod
    
    /// 根据选中周期格式化的日期字符串
    let dateString: String
    
    /// 技术指标数据
    var KLineTechnicalIndicatorsModel: KLineTechnicalIndicatorsModel?
    
    init(klineData: KLineData, selectedPeriod: KLinePeriod) {
        self.klineData = klineData
        self.selectedPeriod = selectedPeriod
        let date = Date(timeIntervalSince1970: TimeInterval(klineData.id))
        
        switch selectedPeriod {
        case .min15, .min60, .hour4:
            // 短周期使用 "0906 12:00" 格式
            let timestamp = TimeInterval(klineData.id)
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            formatter.timeZone = TimeZone(identifier: "Asia/Singapore")
            
            dateString =  formatter.string(from: date)
        default:
            // 其他情况使用 "2025-09-31" 格式
            let timestamp = TimeInterval(klineData.id)
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Singapore")
            dateString = formatter.string(from: date)
        }
    }
    
    /// 便捷访问属性
    var open: Double { return klineData.open }
    var close: Double { return klineData.close }
    var high: Double { return klineData.high }
    var low: Double { return klineData.low }
    var volume: Double { return klineData.vol }
    var amount: Double { return klineData.amount }
    var timestamp: Int64 { return klineData.id }
    
    /// 是否上涨
    var isRising: Bool { return close > open }
    
    /// 涨跌幅
    var changeRate: Double {
        guard open != 0 else { return 0 }
        return (close - open) / open
    }
    
    /// 涨跌额
    var changeAmount: Double { return close - open }
    
    
}
