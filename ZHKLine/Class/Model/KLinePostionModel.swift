//
//  KLinePostionModel.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import CoreGraphics

/// 单个K线对应的技术指标位置
struct SingleIndicatorPosition {
    // MARK: - 主图指标位置
    
    // MA指标位置
    var ma5Point: CGPoint?
    var ma10Point: CGPoint?
    var ma30Point: CGPoint?
    
    // EMA指标位置
    var ema5Point: CGPoint?
    var ema10Point: CGPoint?
    var ema30Point: CGPoint?
    
    // BOLL指标位置
    var bollUpperPoint: CGPoint?
    var bollMiddlePoint: CGPoint?
    var bollLowerPoint: CGPoint?
}

/// K线位置信息模型
struct KLinePositionModel {
    
    // MARK: - 基础位置属性
    
    /**
     蜡烛图在图表中的X坐标（中心线位置）
     */
    var candleCenterX: CGFloat
    /**
    蜡烛图的宽度
    */
    var candleWidth: CGFloat
    /**
     蜡烛实体的顶部Y坐标
     */
    var candleBodyTopY: CGFloat
    /**
     蜡烛实体的底部Y坐标
     */
    var candleBodyBottomY: CGFloat
    /**
     蜡烛上影线的顶部Y坐标
     */
    var candleUpperWickTopY: CGFloat
    /**
     蜡烛下影线的底部Y坐标
     */
    var candleLowerWickBottomY: CGFloat
    
    /**
     当前K线对应的技术指标位置信息
     */
    var indicatorPosition: SingleIndicatorPosition?
    
    // MARK: - 初始化方法
    
    /// 初始化K线位置模型
    /// - Parameters:
    ///   - candleCenterX: 蜡烛图中心X坐标
    ///   - candleWidth: 蜡烛图宽度
    ///   - candleBodyTopY: 蜡烛实体顶部Y坐标
    ///   - candleBodyBottomY: 蜡烛实体底部Y坐标
    ///   - candleUpperWickTopY: 上影线顶部Y坐标
    ///   - candleLowerWickBottomY: 下影线底部Y坐标
    init(candleCenterX: CGFloat = 0,
         candleWidth: CGFloat = 0,
         candleBodyTopY: CGFloat = 0,
         candleBodyBottomY: CGFloat = 0,
         candleUpperWickTopY: CGFloat = 0,
         candleLowerWickBottomY: CGFloat = 0,
         indicatorPosition: SingleIndicatorPosition? = nil) {
        self.candleCenterX = candleCenterX
        self.candleWidth = candleWidth
        self.candleBodyTopY = candleBodyTopY
        self.candleBodyBottomY = candleBodyBottomY
        self.candleUpperWickTopY = candleUpperWickTopY
        self.candleLowerWickBottomY = candleLowerWickBottomY
        self.indicatorPosition = indicatorPosition
    }
    
    // MARK: - 计算属性
    
    /// 获取蜡烛图实体的矩形框
    var candleBodyRect: CGRect {
        let x = candleCenterX - candleWidth / 2
        let y = min(candleBodyTopY, candleBodyBottomY)
        let height = abs(candleBodyTopY - candleBodyBottomY)
        return CGRect(x: x, y: y, width: candleWidth, height: height)
    }
    
    /// 获取蜡烛图左边界X坐标
    var candleLeftX: CGFloat {
        return candleCenterX - candleWidth / 2
    }
    
    /// 获取蜡烛图右边界X坐标
    var candleRightX: CGFloat {
        return candleCenterX + candleWidth / 2
    }
    var candleFrame: CGRect {
        return CGRect(x: candleCenterX - (candleWidth / 2), y: candleBodyTopY, width: candleWidth, height: candleBodyTopY - candleBodyBottomY)
    }
    
    /// 获取上影线的中心点
    var upperWickCenter: CGPoint {
        return CGPoint(x: candleCenterX, y: candleUpperWickTopY)
    }
    
    /// 获取下影线的中心点
    var lowerWickPoint: CGPoint {
        return CGPoint(x: candleCenterX, y: candleLowerWickBottomY)
    }
    
    /// 获取蜡烛图整体的边界矩形
    var candleBounds: CGRect {
        let x = candleLeftX
        let y = candleUpperWickTopY
        let width = candleWidth
        let height = candleLowerWickBottomY - candleUpperWickTopY
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// 获取蜡烛图中心点
    var candleCenter: CGPoint {
        let centerY = (candleUpperWickTopY + candleLowerWickBottomY) / 2
        return CGPoint(x: candleCenterX, y: centerY)
    }
    
    // MARK: - 方法
    
    /// 判断给定的点是否在蜡烛图范围内
    /// - Parameter point: 要检查的点
    /// - Returns: 如果点在蜡烛图范围内返回true
    func containsPoint(_ point: CGPoint) -> Bool {
        let xInRange = point.x >= candleLeftX && point.x <= candleRightX
        let yInRange = point.y >= candleUpperWickTopY && point.y <= candleLowerWickBottomY
        return xInRange && yInRange
    }
    
    /// 判断给定的点是否在蜡烛实体范围内
    /// - Parameter point: 要检查的点
    /// - Returns: 如果点在蜡烛实体范围内返回true
    func containsPointInBody(_ point: CGPoint) -> Bool {
        return candleBodyRect.contains(point)
    }
    
    /// 判断给定的点是否在上影线范围内
    /// - Parameter point: 要检查的点
    /// - Returns: 如果点在上影线范围内返回true
    func containsPointInUpperWick(_ point: CGPoint) -> Bool {
        let xInRange = abs(point.x - candleCenterX) <= 1.0 // 允许1像素的误差
        let yInRange = point.y >= candleUpperWickTopY && point.y <= min(candleBodyTopY, candleBodyBottomY)
        return xInRange && yInRange
    }
    
    /// 判断给定的点是否在下影线范围内
    /// - Parameter point: 要检查的点
    /// - Returns: 如果点在下影线范围内返回true
    func containsPointInLowerWick(_ point: CGPoint) -> Bool {
        let xInRange = abs(point.x - candleCenterX) <= 1.0 // 允许1像素的误差
        let yInRange = point.y >= max(candleBodyTopY, candleBodyBottomY) && point.y <= candleLowerWickBottomY
        
        return xInRange && yInRange
    }
    
    /// 计算到指定点的距离
    /// - Parameter point: 目标点
    /// - Returns: 到目标点的距离
    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        let center = candleCenter
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// 判断是否与另一个位置模型相交
    /// - Parameter other: 另一个位置模型
    /// - Returns: 如果相交返回true
    func intersects(with other: KLinePositionModel) -> Bool {
        return candleBounds.intersects(other.candleBounds)
    }
}
