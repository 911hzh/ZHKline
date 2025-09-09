//
//  DataUtil.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
/// 数据计算工具类
class DataUtil {
    
    /// 计算简单移动平均线 (Simple Moving Average)
    /// - Parameters:
    ///   - prices: 价格数组
    ///   - period: 周期
    /// - Returns: 移动平均值数组
    static func calculateMA(prices: [Double], period: Int) -> [Double?] {
        var results: [Double?] = Array(repeating: nil, count: prices.count)
        
        guard prices.count >= period else { return results }
        
        for i in (period - 1)..<prices.count {
            let sum = prices[(i - period + 1)...i].reduce(0, +)
            results[i] = sum / Double(period)
        }
        
        return results
    }
    
    /// 计算指数移动平均线 (Exponential Moving Average)
    /// - Parameters:
    ///   - prices: 价格数组
    ///   - period: 周期
    /// - Returns: EMA值数组
    static func calculateEMA(prices: [Double], period: Int) -> [Double?] {
        var results: [Double?] = Array(repeating: nil, count: prices.count)
        
        guard prices.count >= period else { return results }
        
        let multiplier = 2.0 / (Double(period) + 1.0)
        
        // 第一个EMA值是SMA
        let smaSum = prices[0..<period].reduce(0, +)
        results[period - 1] = smaSum / Double(period)
        
        // 计算后续EMA值
        for i in period..<prices.count {
            if let previousEMA = results[i - 1] {
                results[i] = (prices[i] - previousEMA) * multiplier + previousEMA
            }
        }
        
        return results
    }
    
    /// 计算布林带 (Bollinger Bands)
    /// - Parameters:
    ///   - prices: 价格数组
    ///   - period: 周期，默认20
    ///   - multiplier: 标准差倍数，默认2
    /// - Returns: (上轨, 中轨, 下轨)
    static func calculateBOLL(prices: [Double], period: Int = 20, multiplier: Double = 2.0) -> (upper: [Double?], middle: [Double?], lower: [Double?]) {
        let ma = calculateMA(prices: prices, period: period)
        var upper: [Double?] = Array(repeating: nil, count: prices.count)
        var lower: [Double?] = Array(repeating: nil, count: prices.count)
        
        for i in (period - 1)..<prices.count {
            if let middleValue = ma[i] {
                // 计算标准差
                let sum = prices[(i - period + 1)...i].reduce(0) { sum, price in
                    sum + pow(price - middleValue, 2)
                }
                let standardDeviation = sqrt(sum / Double(period))
                
                upper[i] = middleValue + multiplier * standardDeviation
                lower[i] = middleValue - multiplier * standardDeviation
            }
        }
        
        return (upper: upper, middle: ma, lower: lower)
    }
    
    /// 计算MACD指标
    /// - Parameters:
    ///   - prices: 价格数组
    ///   - fastPeriod: 快线周期，默认12
    ///   - slowPeriod: 慢线周期，默认26
    ///   - signalPeriod: 信号线周期，默认9
    /// - Returns: (MACD柱, DIF, DEA)
    static func calculateMACD(prices: [Double], fastPeriod: Int = 12, slowPeriod: Int = 26, signalPeriod: Int = 9) -> (macd: [Double?], dif: [Double?], dea: [Double?]) {
        let ema12 = calculateEMA(prices: prices, period: fastPeriod)
        let ema26 = calculateEMA(prices: prices, period: slowPeriod)
        
        var dif: [Double?] = Array(repeating: nil, count: prices.count)
        
        // 计算DIF线
        for i in 0..<prices.count {
            if let fast = ema12[i], let slow = ema26[i] {
                dif[i] = fast - slow
            }
        }
        
        // 计算DEA线（DIF的EMA）
        let difValues = dif.compactMap { $0 }
        let deaResults = calculateEMA(prices: difValues, period: signalPeriod)
        var dea: [Double?] = Array(repeating: nil, count: prices.count)
        
        var deaIndex = 0
        for i in 0..<dif.count {
            if dif[i] != nil {
                if deaIndex < deaResults.count {
                    dea[i] = deaResults[deaIndex]
                }
                deaIndex += 1
            }
        }
        
        // 计算MACD柱
        var macd: [Double?] = Array(repeating: nil, count: prices.count)
        for i in 0..<prices.count {
            if let difValue = dif[i], let deaValue = dea[i] {
                macd[i] = 2 * (difValue - deaValue)
            }
        }
        
        return (macd: macd, dif: dif, dea: dea)
    }
    
    /// 计算KDJ指标
    /// - Parameters:
    ///   - klineData: K线数据数组
    ///   - period: 周期，默认9
    ///   - m1: K值平滑因子，默认3
    ///   - m2: D值平滑因子，默认3
    /// - Returns: (K值, D值, J值)
    static func calculateKDJ(klineData: [KLineData], period: Int = 9, m1: Int = 3, m2: Int = 3) -> (k: [Double?], d: [Double?], j: [Double?]) {
        var k: [Double?] = Array(repeating: nil, count: klineData.count)
        var d: [Double?] = Array(repeating: nil, count: klineData.count)
        var j: [Double?] = Array(repeating: nil, count: klineData.count)
        
        guard klineData.count >= period else { return (k: k, d: d, j: j) }
        
        var rsv: [Double] = []
        
        // 计算RSV
        for i in (period - 1)..<klineData.count {
            let periodData = Array(klineData[(i - period + 1)...i])
            let highest = periodData.map { $0.high }.max() ?? 0
            let lowest = periodData.map { $0.low }.min() ?? 0
            let close = klineData[i].close
            
            let rsvValue = highest == lowest ? 50.0 : ((close - lowest) / (highest - lowest)) * 100
            rsv.append(rsvValue)
        }
        
        // 计算K、D、J值
        var kValue = 50.0
        var dValue = 50.0
        
        for i in 0..<rsv.count {
            kValue = (Double(m1 - 1) * kValue + rsv[i]) / Double(m1)
            dValue = (Double(m2 - 1) * dValue + kValue) / Double(m2)
            let jValue = 3 * kValue - 2 * dValue
            
            let index = i + period - 1
            k[index] = kValue
            d[index] = dValue
            j[index] = jValue
        }
        
        return (k: k, d: d, j: j)
    }
    
    /// 计算RSI相对强弱指标
    /// - Parameters:
    ///   - prices: 价格数组
    ///   - period: 周期
    /// - Returns: RSI值数组
    static func calculateRSI(prices: [Double], period: Int) -> [Double?] {
        var results: [Double?] = Array(repeating: nil, count: prices.count)
        
        guard prices.count > period else { return results }
        
        var gains: [Double] = []
        var losses: [Double] = []
        
        // 计算价格变化
        for i in 1..<prices.count {
            let change = prices[i] - prices[i - 1]
            gains.append(change > 0 ? change : 0)
            losses.append(change < 0 ? -change : 0)
        }
        
        // 计算RSI
        for i in (period - 1)..<gains.count {
            let avgGain = gains[(i - period + 1)...i].reduce(0, +) / Double(period)
            let avgLoss = losses[(i - period + 1)...i].reduce(0, +) / Double(period)
            
            if avgLoss == 0 {
                results[i + 1] = 100
            } else {
                let rs = avgGain / avgLoss
                results[i + 1] = 100 - (100 / (1 + rs))
            }
        }
        
        return results
    }
    
    /// 计算成交量移动平均线
    /// - Parameters:
    ///   - volumes: 成交量数组
    ///   - period: 周期
    /// - Returns: 成交量MA数组
    static func calculateVolumeMA(volumes: [Double], period: Int) -> [Double?] {
        return calculateMA(prices: volumes, period: period)
    }
    
    /// 计算威廉指标(WR)
    /// - Parameters:
    ///   - klineData: K线数据数组
    ///   - period: 周期
    /// - Returns: WR数组
    static func calculateWR(klineData: [KLineData], period: Int) -> [Double?] {
        var results: [Double?] = Array(repeating: nil, count: klineData.count)
        
        guard klineData.count >= period else { return results }
        
        for i in (period - 1)..<klineData.count {
            let startIndex = i - period + 1
            let endIndex = i
            
            // 获取周期内的高低价
            let periodData = Array(klineData[startIndex...endIndex])
            let highs = periodData.map { $0.high }
            let lows = periodData.map { $0.low }
            
            guard let maxHigh = highs.max(),
                  let minLow = lows.min() else {
                continue
            }
            
            let currentClose = klineData[i].close
            
            // WR = (HN - C) / (HN - LN) * 100
            // 其中：HN为N日内最高价，LN为N日内最低价，C为当日收盘价
            if maxHigh != minLow {
                let wr = (maxHigh - currentClose) / (maxHigh - minLow) * 100
                results[i] = -wr // WR通常为负值
            }
        }
        
        return results
    }
    
    /// 将K线数据转换为带技术指标的KLineModel数组
    /// - Parameters:
    ///   - datas: K线数据数组
    ///   - selectedPeriod: 选中的周期
    /// - Returns: 包含技术指标的KLineModel数组
    static func toKLineModelsWithIndicators(datas: [KLineData], selectedPeriod: KLinePeriod) -> [KLineModel] {
        let indicators = calculateAllIndicators(klineData: datas)
        
        // 使用单个循环创建KLineModel并赋值技术指标
        return datas.enumerated().map { index, klineData in
            var model = KLineModel(klineData: klineData, selectedPeriod: selectedPeriod)
            if index < indicators.count {
                model.KLineTechnicalIndicatorsModel = indicators[index]
            }
            return model
        }
    }
    
    /// 为K线数据数组计算所有技术指标
    /// - Parameter klineData: K线数据数组
    /// - Returns: 技术指标数组
    static func calculateAllIndicators(klineData: [KLineData]) -> [KLineTechnicalIndicatorsModel] {
        let closePrices = klineData.map { $0.close }
        let volumes = klineData.map { $0.vol }
        
        // 计算各种技术指标
        let ma5 = calculateMA(prices: closePrices, period: 5)
        let ma10 = calculateMA(prices: closePrices, period: 10)
        let ma30 = calculateMA(prices: closePrices, period: 30)
        
        let ema5 = calculateEMA(prices: closePrices, period: 5)
        let ema10 = calculateEMA(prices: closePrices, period: 10)
        let ema30 = calculateEMA(prices: closePrices, period: 30)
        
        let boll = calculateBOLL(prices: closePrices)
        let macdData = calculateMACD(prices: closePrices)
        let kdjData = calculateKDJ(klineData: klineData)
        
        let rsi6 = calculateRSI(prices: closePrices, period: 6)
        let rsi12 = calculateRSI(prices: closePrices, period: 12)
        let rsi24 = calculateRSI(prices: closePrices, period: 24)
        
        let wr6 = calculateWR(klineData: klineData, period: 6)
        let wr10 = calculateWR(klineData: klineData, period: 10)
        let wr14 = calculateWR(klineData: klineData, period: 14)
        
        let volumeMA5 = calculateVolumeMA(volumes: volumes, period: 5)
        let volumeMA10 = calculateVolumeMA(volumes: volumes, period: 10)
        
        // 组装结果
        var indicators: [KLineTechnicalIndicatorsModel] = []
        
        for i in 0..<klineData.count {
            let indicator = KLineTechnicalIndicatorsModel(
                ma5: ma5[i],
                ma10: ma10[i],
                ma30: ma30[i],
                ema5: ema5[i],
                ema10: ema10[i],
                ema30: ema30[i],
                bollUpper: boll.upper[i],
                bollMiddle: boll.middle[i],
                bollLower: boll.lower[i],
                macd: macdData.macd[i],
                dif: macdData.dif[i],
                dea: macdData.dea[i],
                k: kdjData.k[i],
                d: kdjData.d[i],
                j: kdjData.j[i],
                rsi6: rsi6[i],
                rsi12: rsi12[i],
                rsi24: rsi24[i],
                wr6: wr6[i],
                wr10: wr10[i],
                wr14: wr14[i],
                volumeMA5: volumeMA5[i],
                volumeMA10: volumeMA10[i]
            )
            indicators.append(indicator)
        }
        
        return indicators
    }
}
