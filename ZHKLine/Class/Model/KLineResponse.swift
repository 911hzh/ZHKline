//
//  KLineResponse.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation

/// 火币API K线数据响应模型
struct KLineResponse: Codable {
    /// 频道名称
    let ch: String
    /// 状态
    let status: String
    /// 时间戳
    let ts: Int64
    /// K线数据数组
    let data: [KLineData]
}

/// 单个K线数据模型（对应API响应）
struct KLineData: Codable {
    /// K线ID（时间戳）
    let id: Int64
    /// 开盘价
    let open: Double
    /// 收盘价
    let close: Double
    /// 最低价
    let low: Double
    /// 最高价
    let high: Double
    /// 成交量（币）
    let amount: Double
    /// 成交额
    let vol: Double
    /// 成交笔数
    let count: Int
}
