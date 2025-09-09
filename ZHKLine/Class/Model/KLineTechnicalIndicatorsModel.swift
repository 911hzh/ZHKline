//
//  KLineTechnicalIndicators.swift
//  ZHKLine
//
//  Created by huang on 2025/9/5.
//

import Foundation
/// 技术指标数据结构
struct KLineTechnicalIndicatorsModel {
    // MA均线
    var ma5: Double?
    var ma10: Double?
    var ma30: Double?
    
    // EMA指数移动平均线
    var ema5: Double?
    var ema10: Double?
    var ema30: Double?
    
    // BOLL布林带
    var bollUpper: Double?
    var bollMiddle: Double?
    var bollLower: Double?
    
    // MACD
    var macd: Double?
    var dif: Double?
    var dea: Double?
    
    // KDJ
    var k: Double?
    var d: Double?
    var j: Double?
    
    // RSI相对强弱指标
    var rsi6: Double?
    var rsi12: Double?
    var rsi24: Double?
    
    // WR威廉指标
    var wr6: Double?
    var wr10: Double?
    var wr14: Double?
    
    // 成交量相关
    var volumeMA5: Double?
    var volumeMA10: Double?
}
