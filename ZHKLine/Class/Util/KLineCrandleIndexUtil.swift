//
//  KLineCrandleIndexUtil.swift
//  ZHKLine
//
//  Created by huang on 2025/9/5.
//

import Foundation
class KLineCrandleIndexUtil {
    
    /**
     计算出需要显示的蜡烛数据，以及位置信息，以及最大最小值等
     */
    static func computerSize(
        datas: [KLineModel],
        drawMaxWidth: CGFloat,
        offset: CGFloat,
        crandleWidth: CGFloat,
        crandleSpace: CGFloat,
        totalHeight: CGFloat,
        indicatorSelection: [KLineTechnicalIndicatorType] = []
    ) -> (showDatas: [KLineModel], positionModels: [KLinePositionModel], maxPrice: CGFloat, minPrice: CGFloat, indexBegin: Int, indexEnd: Int) {
        // 获取可见范围的索引
        let indexResult = Self.findStartAndEndIndex(drawMaxWidth: drawMaxWidth, offset: offset, crandleWidth: crandleWidth, crandleSpace: crandleSpace, datasCount: datas.count)
        if indexResult.0 < 0 || indexResult.1 > datas.count {
            print("array beyound")
            return ([],[],0,0,0,0)
        }
        print("index: begin: \(indexResult.0), end: \(indexResult.1)")
        // 提取可见范围内的数据
        let showedArray = Array(datas[indexResult.0...indexResult.1])
        
        // 计算可见数据的最大和最小价格（包含技术指标）
        let priceResult = Self.findMaxAndMinPrice(showedArray: showedArray, indicatorSelection: indicatorSelection)
        var positionModels: [KLinePositionModel] = []
        for i in indexResult.0 ... indexResult.1 {
            let itemX: CGFloat = CGFloat(i) * CGFloat((KLineConfig.shared.candleSpace + KLineConfig.shared.candleWidth))
            let item = datas[i].klineData
            let klineModel = datas[i]
            
            // 计算基础K线位置
            let centerX = itemX - offset + KLineConfig.shared.crandleInsets.left + KLineConfig.shared.candleWidth/2
            
            // 计算当前K线的技术指标位置
            var indicatorPosition = SingleIndicatorPosition()
            if let indicators = klineModel.KLineTechnicalIndicatorsModel {
                // MA指标位置
                if indicatorSelection.contains(.ma) {
                    if let ma5 = indicators.ma5 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ma5), totalHeight: totalHeight)
                        indicatorPosition.ma5Point = CGPoint(x: centerX, y: y)
                    }
                    if let ma10 = indicators.ma10 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ma10), totalHeight: totalHeight)
                        indicatorPosition.ma10Point = CGPoint(x: centerX, y: y)
                    }
                    if let ma30 = indicators.ma30 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ma30), totalHeight: totalHeight)
                        indicatorPosition.ma30Point = CGPoint(x: centerX, y: y)
                    }
                }
                
                // EMA指标位置
                if indicatorSelection.contains(.ema) {
                    if let ema5 = indicators.ema5 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ema5), totalHeight: totalHeight)
                        indicatorPosition.ema5Point = CGPoint(x: centerX, y: y)
                    }
                    if let ema10 = indicators.ema10 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ema10), totalHeight: totalHeight)
                        indicatorPosition.ema10Point = CGPoint(x: centerX, y: y)
                    }
                    if let ema30 = indicators.ema30 {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(ema30), totalHeight: totalHeight)
                        indicatorPosition.ema30Point = CGPoint(x: centerX, y: y)
                    }
                }
                
                // BOLL指标位置
                if indicatorSelection.contains(.boll) {
                    if let bollUpper = indicators.bollUpper {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(bollUpper), totalHeight: totalHeight)
                        indicatorPosition.bollUpperPoint = CGPoint(x: centerX, y: y)
                    }
                    if let bollMiddle = indicators.bollMiddle {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(bollMiddle), totalHeight: totalHeight)
                        indicatorPosition.bollMiddlePoint = CGPoint(x: centerX, y: y)
                    }
                    if let bollLower = indicators.bollLower {
                        let y = totalHeight - computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: CGFloat(bollLower), totalHeight: totalHeight)
                        indicatorPosition.bollLowerPoint = CGPoint(x: centerX, y: y)
                    }
                }
            }
            
            let positionModel = KLinePositionModel.init(
                candleCenterX: centerX,
                candleWidth: KLineConfig.shared.candleWidth,
                candleBodyTopY: computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: max(item.close, item.open), totalHeight: totalHeight),
                candleBodyBottomY: computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: min(item.close, item.open), totalHeight: totalHeight),
                candleUpperWickTopY: computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: item.high, totalHeight: totalHeight),
                candleLowerWickBottomY: computerPositionY(maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, value: item.low, totalHeight: totalHeight),
                indicatorPosition: indicatorPosition
            )
            positionModels.append(positionModel)
            print("index: centerx: \(positionModel.candleCenterX) indexValue: \(i)")
        }
        
        return (showDatas: showedArray, positionModels: positionModels, maxPrice: priceResult.maxPrice, minPrice: priceResult.minPrice, indexResult.0, indexResult.1)
    }
    
}

fileprivate extension KLineCrandleIndexUtil {
    /**
     计算出当前屏幕中需要渲染的蜡烛图的索引
     */
    private static func findStartAndEndIndex(
        drawMaxWidth: CGFloat,
        offset: CGFloat,
        crandleWidth: CGFloat,
        crandleSpace: CGFloat,
        datasCount: Int
    ) -> (Int, Int) {
        let itemWidth = crandleWidth + crandleSpace
        
        // 计算左边界索引 - 使用 floor 来取更小的值
//        let leftIndex = Int(floor((offset - 2) / itemWidth))
        let leftIndex = Int(offset / itemWidth)
        
        // 计算可见范围内能显示多少个蜡烛
        let visibleCount = Int(ceil(drawMaxWidth / itemWidth)) + 2 // +1 确保边界处理
        
        // 计算右边界索引 - 使用 ceil 来取更大的值
        let rightIndex = leftIndex + visibleCount
        
        // 确保索引在有效范围内
        let startIndex = max(0, leftIndex)
        let endIndex = min(datasCount - 1, rightIndex)
        print("startIndex: \(startIndex), endIndex: \(endIndex), offset: \(offset), visibleCount: \(visibleCount)")
        
        return (min(startIndex, endIndex), endIndex)
    }
    static func computerPositionY(
        maxPrice: CGFloat,
        minPrice: CGFloat,
        value: CGFloat,
        totalHeight: CGFloat
    ) -> CGFloat {
        let onePriceHeight = totalHeight / (maxPrice - minPrice)
        return (value - minPrice) * onePriceHeight
    }
    

    static func findMaxAndMinPrice(
        showedArray: [KLineModel],
        indicatorSelection: [KLineTechnicalIndicatorType] = []
    ) -> (maxPrice: CGFloat, minPrice: CGFloat) {
        // 检查数组是否为空
        guard !showedArray.isEmpty else {
            return (maxPrice: 0.0, minPrice: 0.0)
        }
        
        // 初始化最大值和最小值为第一个元素的价格
        let firstData = showedArray.first!
        var maxPrice = max(firstData.klineData.high, firstData.klineData.low, firstData.klineData.open, firstData.klineData.close)
        var minPrice = min(firstData.klineData.high, firstData.klineData.low, firstData.klineData.open, firstData.klineData.close)
        
        // 遍历所有蜡烛数据，找到最大和最小价格
        for data in showedArray {
            let currentHigh = data.klineData.high
            let currentLow = data.klineData.low
            let currentOpen = data.klineData.open
            let currentClose = data.klineData.close
            
            // 找到当前蜡烛的最高价和最低价
            var currentMaxPrice = max(currentHigh, currentLow, currentOpen, currentClose)
            var currentMinPrice = min(currentHigh, currentLow, currentOpen, currentClose)
            
            // 根据选择的技术指标，将指标值也纳入价格范围计算
            if let indicators = data.KLineTechnicalIndicatorsModel {
                
                // MA指标
                if indicatorSelection.contains(.ma) {
                    if let ma5 = indicators.ma5 {
                        currentMaxPrice = max(currentMaxPrice, ma5)
                        currentMinPrice = min(currentMinPrice, ma5)
                    }
                    if let ma10 = indicators.ma10 {
                        currentMaxPrice = max(currentMaxPrice, ma10)
                        currentMinPrice = min(currentMinPrice, ma10)
                    }
                    if let ma30 = indicators.ma30 {
                        currentMaxPrice = max(currentMaxPrice, ma30)
                        currentMinPrice = min(currentMinPrice, ma30)
                    }
                }
                
                // EMA指标
                if indicatorSelection.contains(.ema) {
                    if let ema5 = indicators.ema5 {
                        currentMaxPrice = max(currentMaxPrice, ema5)
                        currentMinPrice = min(currentMinPrice, ema5)
                    }
                    if let ema10 = indicators.ema10 {
                        currentMaxPrice = max(currentMaxPrice, ema10)
                        currentMinPrice = min(currentMinPrice, ema10)
                    }
                    if let ema30 = indicators.ema30 {
                        currentMaxPrice = max(currentMaxPrice, ema30)
                        currentMinPrice = min(currentMinPrice, ema30)
                    }
                }
                
                // BOLL指标
                if indicatorSelection.contains(.boll) {
                    if let bollUpper = indicators.bollUpper {
                        currentMaxPrice = max(currentMaxPrice, bollUpper)
                    }
                    if let bollLower = indicators.bollLower {
                        currentMinPrice = min(currentMinPrice, bollLower)
                    }
                    if let bollMiddle = indicators.bollMiddle {
                        currentMaxPrice = max(currentMaxPrice, bollMiddle)
                        currentMinPrice = min(currentMinPrice, bollMiddle)
                    }
                }
            }
            
            // 更新全局最大值和最小值
            if currentMaxPrice > maxPrice {
                maxPrice = currentMaxPrice
            }
            if currentMinPrice < minPrice {
                minPrice = currentMinPrice
            }
        }
        
        // 转换为 CGFloat 类型返回
        return (maxPrice: CGFloat(maxPrice), minPrice: CGFloat(minPrice))
    }
    
}
