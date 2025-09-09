//
//  KLineLayerUtil.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import QuartzCore
import UIKit


class KLineLayerUtil {
    static func createCrossLayer(
        size: CGSize,
        topHeight: CGFloat,
        bottomHeight: CGFloat,
        horLine: Int,
        verticalLine: Int,
        lineWidth: CGFloat,
        lineColor: UIColor,
        horLineText: [String],
        verticalLineText: [String]
    ) -> CAShapeLayer {
        let layer = KLineBaseLayer()
        let uiBezierPath = UIBezierPath()
        
        // 计算偏移量以避免边界裁剪
        let offset = lineWidth / 2.0
        
        // 绘制顶部边界线
        uiBezierPath.move(to: CGPoint(x: offset, y: offset))
        uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: offset))
        
        let itemHeight = (size.height - topHeight - bottomHeight - offset) / CGFloat((horLine - 1))
        let itemWidth = (size.width - offset * 2) / CGFloat(verticalLine - 1)
        var lastY = topHeight
        
        // 绘制横线
        for i in 0 ..< horLine {
            let textLayer = Self.createTextLayer(fontColor: lineColor, text: horLineText[i])
            var oldFrame = textLayer.frame
            if (i == 0) {
                uiBezierPath.move(to: CGPoint(x: offset, y: lastY))
                uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: lastY))
                oldFrame.origin = CGPoint(x: size.width - oldFrame.size.width - 2, y: lastY + lineWidth)
            } else {
                uiBezierPath.move(to: CGPoint(x: offset, y: lastY))
                uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: lastY))
                oldFrame.origin = CGPoint(x: size.width - oldFrame.size.width - 2, y: lastY - oldFrame.size.height - lineWidth)
            }
            textLayer.frame = oldFrame
            lastY += itemHeight
            layer.addSublayer(textLayer)
            print("frame horLine: \(oldFrame), text: \(horLineText[i])")
        }
        
        // 绘制底部边界线
        uiBezierPath.move(to: CGPoint(x: offset, y: size.height - offset))
        uiBezierPath.addLine(to: CGPoint(x: size.width - offset, y: size.height - offset))
        
        var lastX: CGFloat = offset
        
        // 绘制竖线
        for i in 0 ..< verticalLine {
            uiBezierPath.move(to: CGPoint(x: lastX, y: offset))
            uiBezierPath.addLine(to: CGPoint(x: lastX, y: size.height - bottomHeight - offset))
            let textLayer = Self.createTextLayer(fontColor: lineColor, text: verticalLineText[i])
            var oldFrame = textLayer.frame
            oldFrame.origin = CGPoint(x: lastX - oldFrame.size.width/2, y: size.height - (bottomHeight + oldFrame.height)/2 - offset )
            textLayer.frame = oldFrame
            lastX += itemWidth
            layer.addSublayer(textLayer)
            print("frame verticalLine: \(oldFrame), text: \(verticalLineText[i])")
        }
        
        layer.path = uiBezierPath.cgPath
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }
    static func createTextLayer(fontColor: UIColor, text: String) -> CATextLayer {
        let layer = CATextLayer()
        layer.font = UIFont.systemFont(ofSize: 10)  // 增加字体大小
        layer.fontSize = 10  // 明确设置字体大小
        layer.foregroundColor = fontColor.cgColor
        layer.string = text
        layer.contentsScale = UIScreen.main.scale  // 设置屏幕缩放比例
        layer.alignmentMode = .left  // 设置对齐方式
        
        // 计算文本大小
        let textSize = (text as NSString).size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 10)  // 使用相同的字体大小
        ])
        var frame = layer.frame
        frame.size = textSize
        layer.frame = frame
        return layer
    }
    static func createCrandleLayer(
        datas: [KLineModel],
        positionDatas: [KLinePositionModel],
        indexBound: (begin: Int, end: Int),
        indicatorSelection: [KLineTechnicalIndicatorType] = []
    ) -> KLineBaseLayer {
        let containerLayer = KLineBaseLayer()
        // 分别创建涨跌蜡烛的路径（包含实体和影线）
        let upBezierPath = UIBezierPath()
        let downBezierPath = UIBezierPath()
        
        // 遍历所有KLineModel数据，绘制每个蜡烛图
        for (index, klineModel) in datas.enumerated() {
            // 确保klinePosition存在
            let position = positionDatas[index]
            // 判断蜡烛是涨还是跌
            let isRising = klineModel.klineData.close >= klineModel.klineData.open
            
            // 绘制蜡烛实体（矩形）
            let candleBodyRect = position.candleBodyRect
            
            // 创建包含实体和影线的完整路径
            let completePath = UIBezierPath()
            
            // 添加蜡烛实体
            completePath.append(UIBezierPath(rect: candleBodyRect))
            
            // 添加上影线
            completePath.move(to: CGPoint(x: position.candleCenterX, y: position.candleUpperWickTopY))
            completePath.addLine(to: CGPoint(x: position.candleCenterX, y: min(position.candleBodyTopY, position.candleBodyBottomY)))
            
            // 添加下影线
            completePath.move(to: CGPoint(x: position.candleCenterX, y: max(position.candleBodyTopY, position.candleBodyBottomY)))
            completePath.addLine(to: CGPoint(x: position.candleCenterX, y: position.candleLowerWickBottomY))
            
            // 根据涨跌情况添加到不同的路径
            if isRising {
                upBezierPath.append(completePath)
            } else {
                downBezierPath.append(completePath)
            }
        }
        
        // 创建涨势蜡烛图层（包含实体和影线）
        if !upBezierPath.isEmpty {
            let upLayer = KLineBaseLayer()
            upLayer.path = upBezierPath.cgPath
            upLayer.fillColor = KLineConfig.shared.candleUpColor.cgColor
            upLayer.strokeColor = KLineConfig.shared.candleUpColor.cgColor
            upLayer.lineWidth = KLineConfig.shared.candleMidleLineWidth
            containerLayer.addSublayer(upLayer)
        }
        
        // 创建跌势蜡烛图层（包含实体和影线）
        if !downBezierPath.isEmpty {
            let downLayer = KLineBaseLayer()
            downLayer.path = downBezierPath.cgPath
            downLayer.fillColor = KLineConfig.shared.candleDownColor.cgColor
            downLayer.strokeColor = KLineConfig.shared.candleDownColor.cgColor
            downLayer.lineWidth = KLineConfig.shared.candleMidleLineWidth
            containerLayer.addSublayer(downLayer)
        }
        
        // 直接使用KLinePositionModel绘制主图技术指标
        addTechnicalIndicatorLayers(to: containerLayer, positionModels: positionDatas, indicatorSelection: indicatorSelection)
        
        return containerLayer
    }
    
    /// 添加技术指标图层到容器中
    static func addTechnicalIndicatorLayers(to containerLayer: KLineBaseLayer, positionModels: [KLinePositionModel], indicatorSelection: [KLineTechnicalIndicatorType]) {
        // 使用配置文件中的颜色
        let config = KLineConfig.shared
        
        // 只绘制用户选择的技术指标
        if indicatorSelection.contains(.ma) {
            let ma5Points = positionModels.compactMap { $0.indicatorPosition?.ma5Point }
            let ma10Points = positionModels.compactMap { $0.indicatorPosition?.ma10Point }
            let ma30Points = positionModels.compactMap { $0.indicatorPosition?.ma30Point }
            
            addIndicatorLayerIfNeeded(to: containerLayer, points: ma5Points, color: config.ma5Color)
            addIndicatorLayerIfNeeded(to: containerLayer, points: ma10Points, color: config.ma10Color)
            addIndicatorLayerIfNeeded(to: containerLayer, points: ma30Points, color: config.ma30Color)
        }
        
        if indicatorSelection.contains(.ema) {
            let ema5Points = positionModels.compactMap { $0.indicatorPosition?.ema5Point }
            let ema10Points = positionModels.compactMap { $0.indicatorPosition?.ema10Point }
            let ema30Points = positionModels.compactMap { $0.indicatorPosition?.ema30Point }
            
            addIndicatorLayerIfNeeded(to: containerLayer, points: ema5Points, color: config.ema5Color)
            addIndicatorLayerIfNeeded(to: containerLayer, points: ema10Points, color: config.ema10Color)
            addIndicatorLayerIfNeeded(to: containerLayer, points: ema30Points, color: config.ema30Color)
        }
        
        if indicatorSelection.contains(.boll) {
            let bollUpperPoints = positionModels.compactMap { $0.indicatorPosition?.bollUpperPoint }
            let bollMiddlePoints = positionModels.compactMap { $0.indicatorPosition?.bollMiddlePoint }
            let bollLowerPoints = positionModels.compactMap { $0.indicatorPosition?.bollLowerPoint }
            
            addIndicatorLayerIfNeeded(to: containerLayer, points: bollUpperPoints, color: config.bollUpperColor)
            addIndicatorLayerIfNeeded(to: containerLayer, points: bollMiddlePoints, color: config.bollMiddleColor)
            addIndicatorLayerIfNeeded(to: containerLayer, points: bollLowerPoints, color: config.bollLowerColor)
        }
    }
    
    /// 添加技术指标图层（如果有数据）
    private static func addIndicatorLayerIfNeeded(to containerLayer: KLineBaseLayer, points: [CGPoint], color: UIColor, lineWidth: CGFloat = 1.0) {
        guard let path = createIndicatorLinePath(points: points) else { return }
        
        let lineLayer = KLineBaseLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.fillColor = UIColor.clear.cgColor
        containerLayer.addSublayer(lineLayer)
    }
    

    
    /// 创建技术指标线路径的通用方法（纯函数）
    static func createIndicatorLinePath(points: [CGPoint]) -> UIBezierPath? {
        guard !points.isEmpty else { return nil }
        
        let path = UIBezierPath()
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        return path
    }
    
    
    static func createVerticalShowTexts(
        lineCount: Int,
        klineModels: [KLineModel]
    ) -> [String] {
        var array: [String] = []
        for i in 0..<lineCount {
            if i < klineModels.count {
                array.append(klineModels[i].dateString)
                continue
            }
            array.append("")
        }
        return array
    }
    static func createHorShowTexts(lineCount: Int, maxPrice: CGFloat, minPrice: CGFloat) -> [String] {
        var array: [String] = []
        let itemPrice = (maxPrice - minPrice) / 2
        for i in 0..<lineCount {
            var number = i == 0 ? minPrice : (minPrice + itemPrice)
            number = (i == lineCount - 1) ? maxPrice : number
            let formatted = String(format: "%.2f", number)
            array.append(formatted)
        }
        return array
    }
    
    /// 创建十字线容器（包含线条、圆点和日期标签）
    /// - Parameters:
    ///   - point: 十字线交叉点位置
    ///   - containerSize: 容器大小
    ///   - verticalLineTopY: 垂直线顶部Y坐标
    ///   - verticalLineBottomY: 垂直线底部Y坐标
    ///   - horizontalLineLeftX: 水平线左端X坐标
    ///   - horizontalLineRightX: 水平线右端X坐标
    ///   - crossLineColor: 十字线颜色
    ///   - crossLineWidth: 十字线宽度
    ///   - selectedKLineModel: 选中的K线数据（用于显示日期）
    ///   - bottomHeight: 底部高度（对应 crandleInset.bottom）
    ///   - lineWidth: 线条宽度（用于计算偏移）
    /// - Returns: 包含所有十字线元素的容器图层
    static func createCrossLineContainer(
        point: CGPoint,
        containerSize: CGSize,
        verticalLineTopY: CGFloat,
        verticalLineBottomY: CGFloat,
        horizontalLineLeftX: CGFloat,
        horizontalLineRightX: CGFloat,
        crossLineColor: UIColor,
        crossLineWidth: CGFloat,
        selectedKLineModel: KLineModel?,
        bottomHeight: CGFloat,
        lineWidth: CGFloat
    ) -> CALayer {
        let containerLayer = CALayer()
        containerLayer.frame = CGRect(origin: .zero, size: containerSize)
        
        // 3. 创建日期标签图层（如果有选中的K线数据）并获取其frame
        var dateLabelFrame = CGRect.zero
        if let klineModel = selectedKLineModel {
            // 先计算日期标签的frame
            let timestamp = TimeInterval(klineModel.timestamp)
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Singapore")
            let dateString = formatter.string(from: date)
            
            let textSize = (dateString as NSString).size(withAttributes: [
                .font: UIFont.systemFont(ofSize: 10)
            ])
            
            let padding: CGFloat = 4
            let labelWidth = textSize.width + padding * 2
            let labelHeight = bottomHeight
            let labelX = max(padding, min(point.x - labelWidth / 2, containerSize.width - labelWidth - padding))
            let labelY = containerSize.height - bottomHeight
            
            dateLabelFrame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
        
        // 1. 创建十字线图层
        let crossLineLayer = createCrossLineLayer(
            point: point,
            verticalLineTopY: verticalLineTopY,
            verticalLineBottomY: verticalLineBottomY,
            horizontalLineLeftX: horizontalLineLeftX,
            horizontalLineRightX: horizontalLineRightX,
            crossLineColor: crossLineColor,
            crossLineWidth: crossLineWidth,
            dateLabelFrame: dateLabelFrame
        )
        
        // 2. 创建圆点图层
        let dotLayer = createCrossLineDotLayer(
            point: point,
            crossLineColor: crossLineColor
        )
        
        // 3. 创建日期标签图层（如果有选中的K线数据）
        if let klineModel = selectedKLineModel {
            let dateLabelLayer = createDateLabelLayer(
                dateLabelFrame: dateLabelFrame,
                klineModel: klineModel
            )
            containerLayer.addSublayer(dateLabelLayer)
        }
        
        // 添加图层到容器（先线条，再圆点，最后日期标签）
        containerLayer.addSublayer(crossLineLayer)
        containerLayer.addSublayer(dotLayer)
        
        return containerLayer
    }
    
    /// 创建十字线图层（线条部分）
    /// - Parameters:
    ///   - point: 交叉点位置
    ///   - verticalLineTopY: 垂直线顶部Y坐标
    ///   - verticalLineBottomY: 垂直线底部Y坐标
    ///   - horizontalLineLeftX: 水平线左端X坐标
    ///   - horizontalLineRightX: 水平线右端X坐标
    ///   - crossLineColor: 线条颜色
    ///   - crossLineWidth: 线条宽度
    ///   - dateLabelFrame: 日期标签的frame（垂直线在此处断开）
    /// - Returns: 十字线图层
    private static func createCrossLineLayer(
        point: CGPoint,
        verticalLineTopY: CGFloat,
        verticalLineBottomY: CGFloat,
        horizontalLineLeftX: CGFloat,
        horizontalLineRightX: CGFloat,
        crossLineColor: UIColor,
        crossLineWidth: CGFloat,
        dateLabelFrame: CGRect
    ) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        
        // 绘制垂直线（在日期标签处断开）
        // 检查垂直线是否会与日期标签相交
        if point.x >= dateLabelFrame.minX && point.x <= dateLabelFrame.maxX {
            // 垂直线会穿过日期标签，需要分段绘制
            // 上半部分：从顶部到日期标签开始
            linePath.move(to: CGPoint(x: point.x, y: verticalLineTopY))
            linePath.addLine(to: CGPoint(x: point.x, y: dateLabelFrame.minY))
            
            // 下半部分：从日期标签结束到底部
            linePath.move(to: CGPoint(x: point.x, y: dateLabelFrame.maxY))
            linePath.addLine(to: CGPoint(x: point.x, y: verticalLineBottomY))
        } else {
            // 垂直线不会穿过日期标签，正常绘制
            linePath.move(to: CGPoint(x: point.x, y: verticalLineTopY))
            linePath.addLine(to: CGPoint(x: point.x, y: verticalLineBottomY))
        }
        
        // 绘制水平线
        linePath.move(to: CGPoint(x: horizontalLineLeftX, y: point.y))
        linePath.addLine(to: CGPoint(x: horizontalLineRightX, y: point.y))
        
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = crossLineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = crossLineWidth
        lineLayer.lineCap = .round
        
        return lineLayer
    }
    
    /// 创建十字线圆点图层
    /// - Parameters:
    ///   - point: 圆点中心位置
    ///   - crossLineColor: 圆点边框颜色
    /// - Returns: 圆点图层
    private static func createCrossLineDotLayer(
        point: CGPoint,
        crossLineColor: UIColor
    ) -> CAShapeLayer {
        let dotLayer = CAShapeLayer()
        let dotPath = UIBezierPath()
        let dotRadius: CGFloat = 3
        
        dotPath.addArc(withCenter: point, radius: dotRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        dotLayer.path = dotPath.cgPath
        dotLayer.strokeColor = crossLineColor.cgColor
        dotLayer.fillColor = UIColor.black.cgColor
        dotLayer.lineWidth = 1
        
        return dotLayer
    }
    
    /// 创建日期标签图层
    /// - Parameters:
    ///   - dateLabelFrame: 日期标签的frame
    ///   - klineModel: 选中的K线数据
    /// - Returns: 日期标签图层
    private static func createDateLabelLayer(
        dateLabelFrame: CGRect,
        klineModel: KLineModel
    ) -> CALayer {
        // 格式化日期
        let dateString = klineModel.dateString
        
        // 创建文本图层（使用与网格线相同的字体大小）
        let textLayer = CATextLayer()
        textLayer.font = UIFont.systemFont(ofSize: 10)
        textLayer.fontSize = 10
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.string = dateString
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        
        // 计算文本大小（使用与网格线相同的字体大小）
        let textSize = (dateString as NSString).size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 10)
        ])
        
        let padding: CGFloat = 4
        
        // 创建背景图层（黑色边框，白色背景，无圆角）
        let backgroundLayer = CAShapeLayer()
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: dateLabelFrame.width, height: dateLabelFrame.height))
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = UIColor.white.cgColor
        backgroundLayer.strokeColor = UIColor.black.cgColor
        backgroundLayer.lineWidth = 1
        
        // 创建容器图层
        let containerLayer = CALayer()
        containerLayer.frame = dateLabelFrame
        
        // 设置子图层frame
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: dateLabelFrame.width, height: dateLabelFrame.height)
        textLayer.frame = CGRect(x: padding, y: (dateLabelFrame.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        
        // 添加到容器
        containerLayer.addSublayer(backgroundLayer)
        containerLayer.addSublayer(textLayer)
        
        return containerLayer
    }
}

