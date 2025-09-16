//
//  DataUtilTests.swift
//  ZHKLineTests
//
//  Created by huang on 2025/9/16.
//

import XCTest
@testable import ZHKLine

/// DataUtil 工具类的单元测试
final class DataUtilTests: XCTestCase {

    override func setUpWithError() throws {
        // 每个测试方法执行前的设置代码
    }

    override func tearDownWithError() throws {
        // 每个测试方法执行后的清理代码
    }

    // MARK: - EMA Tests
    /// 测试EMA计算的基本功能
    func testCalculateEMA_BasicFunctionality() throws {
        // 测试数据：简单的价格序列
        let prices = [10.0, 12.0, 13.0, 15.0, 14.0, 16.0, 18.0]
        let period = 3
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        // 验证结果数组长度
        XCTAssertEqual(result.count, prices.count, "结果数组长度应该与输入价格数组长度相同")
        
        // 验证前两个值应该为nil（因为周期为3）
        XCTAssertNil(result[0], "第一个值应该为nil")
        XCTAssertNil(result[1], "第二个值应该为nil")
        
        // 验证第三个值（应该是SMA）
        let expectedSMA = (10.0 + 12.0 + 13.0) / 3.0
        XCTAssertNotNil(result[2], "第三个值应该不为nil")
        XCTAssertEqual(result[2]!, expectedSMA, accuracy: 0.0001, "第三个值应该等于SMA")
        
        // 验证后续值不为nil
        for i in 3..<result.count {
            XCTAssertNotNil(result[i], "索引\(i)处的值应该不为nil")
        }
    }
    
    /// 测试EMA计算的数学准确性
    func testCalculateEMA_MathematicalAccuracy() throws {
        let prices = [2.0, 4.0, 6.0, 8.0, 10.0]
        let period = 3
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        let multiplier = 2.0 / (Double(period) + 1.0) // 0.5
        
        // 手动计算验证
        // 第一个EMA（索引2）= SMA = (2+4+6)/3 = 4.0
        XCTAssertEqual(result[2]!, 4.0, accuracy: 0.0001)
        
        // 第二个EMA（索引3）= (8 - 4) * 0.5 + 4 = 2 + 4 = 6.0
        XCTAssertEqual(result[3]!, 6.0, accuracy: 0.0001)
        
        // 第三个EMA（索引4）= (10 - 6) * 0.5 + 6 = 2 + 6 = 8.0
        XCTAssertEqual(result[4]!, 8.0, accuracy: 0.0001)
    }
    
    /// 测试边界条件：空数组
    func testCalculateEMA_EmptyArray() throws {
        let prices: [Double] = []
        let period = 5
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        XCTAssertTrue(result.isEmpty, "空数组的结果应该是空数组")
    }
    
    /// 测试边界条件：数组长度小于周期
    func testCalculateEMA_ArraySmallerThanPeriod() throws {
        let prices = [1.0, 2.0]
        let period = 5
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        XCTAssertEqual(result.count, prices.count, "结果数组长度应该与输入相同")
        
        // 所有值都应该为nil
        for i in 0..<result.count {
            XCTAssertNil(result[i], "当数组长度小于周期时，所有值都应该为nil")
        }
    }
    
    /// 测试边界条件：数组长度等于周期
    func testCalculateEMA_ArrayEqualToPeriod() throws {
        let prices = [1.0, 2.0, 3.0, 4.0, 5.0]
        let period = 5
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        XCTAssertEqual(result.count, prices.count)
        
        // 前4个值应该为nil
        for i in 0..<(period - 1) {
            XCTAssertNil(result[i], "索引\(i)处的值应该为nil")
        }
        
        // 最后一个值应该等于SMA
        let expectedSMA = prices.reduce(0, +) / Double(prices.count)
        XCTAssertNotNil(result[period - 1], "最后一个值应该不为nil")
        XCTAssertEqual(result[period - 1]!, expectedSMA, accuracy: 0.0001)
    }
    
    /// 测试特殊值：包含相同价格
    func testCalculateEMA_SamePrices() throws {
        let prices = [5.0, 5.0, 5.0, 5.0, 5.0]
        let period = 3
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        // 当所有价格相同时，EMA应该等于该价格
        for i in (period - 1)..<result.count {
            XCTAssertNotNil(result[i], "索引\(i)处的值应该不为nil")
            XCTAssertEqual(result[i]!, 5.0, accuracy: 0.0001, "相同价格的EMA应该等于该价格")
        }
    }
    
    /// 测试性能：大数据集
    func testCalculateEMA_Performance() throws {
        // 生成100个随机价格（减少数据量以避免测试卡住）
        let prices = (0..<100).map { _ in Double.random(in: 1.0...100.0) }
        let period = 20
        
        // 简单的性能测试，不使用measure来避免重复执行
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // 验证结果不为空且计算时间合理（小于1秒）
        XCTAssertFalse(result.isEmpty, "结果不应该为空")
        XCTAssertLessThan(timeElapsed, 1.0, "计算时间应该小于1秒")
        
        // 验证结果的基本正确性
        XCTAssertEqual(result.count, prices.count, "结果数组长度应该与输入相同")
        for i in 0..<(period - 1) {
            XCTAssertNil(result[i], "前\(period-1)个值应该为nil")
        }
        for i in (period - 1)..<result.count {
            XCTAssertNotNil(result[i], "从第\(period)个值开始应该不为nil")
        }
    }
    
    /// 测试不同周期的EMA计算
    func testCalculateEMA_DifferentPeriods() throws {
        let prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
        
        // 测试周期为1（应该等于原价格）
        let result1 = DataUtil.calculateEMA(prices: prices, period: 1)
        XCTAssertNotNil(result1[0])
        XCTAssertEqual(result1[0]!, prices[0], accuracy: 0.0001)
        
        // 测试周期为2
        let result2 = DataUtil.calculateEMA(prices: prices, period: 2)
        XCTAssertNil(result2[0])
        XCTAssertNotNil(result2[1])
        
        // 测试周期为10（等于数组长度）
        let result10 = DataUtil.calculateEMA(prices: prices, period: 10)
        for i in 0..<9 {
            XCTAssertNil(result10[i], "索引\(i)处应该为nil")
        }
        XCTAssertNotNil(result10[9], "最后一个值应该不为nil")
    }
    
    /// 测试EMA计算的连续性
    func testCalculateEMA_Continuity() throws {
        let prices = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0]
        let period = 3
        
        let result = DataUtil.calculateEMA(prices: prices, period: period)
        
        // 验证EMA值是连续递增的（因为价格是递增的）
        for i in (period)..<result.count {
            if let current = result[i], let previous = result[i - 1] {
                XCTAssertGreaterThan(current, previous, "递增价格序列的EMA应该是递增的")
            }
        }
    }

    // MARK: - SMA Tests
    
    /// 测试简单移动平均线(SMA)计算的基本功能
    func testCalculateMA_BasicFunctionality() throws {
        let prices = [1.0, 2.0, 3.0, 4.0, 5.0]
        let period = 3
        
        let result = DataUtil.calculateMA(prices: prices, period: period)
        
        // 验证结果数组长度
        XCTAssertEqual(result.count, prices.count, "结果数组长度应该与输入价格数组长度相同")
        
        // 验证前两个值应该为nil（因为周期为3）
        XCTAssertNil(result[0], "第一个值应该为nil")
        XCTAssertNil(result[1], "第二个值应该为nil")
        
        // 验证SMA计算
        XCTAssertEqual(result[2]!, 2.0, accuracy: 0.0001, "第三个值应该是(1+2+3)/3 = 2.0")
        XCTAssertEqual(result[3]!, 3.0, accuracy: 0.0001, "第四个值应该是(2+3+4)/3 = 3.0")
        XCTAssertEqual(result[4]!, 4.0, accuracy: 0.0001, "第五个值应该是(3+4+5)/3 = 4.0")
    }
    
    /// 测试SMA边界条件
    func testCalculateMA_EdgeCases() throws {
        // 测试空数组
        let emptyPrices: [Double] = []
        let emptyResult = DataUtil.calculateMA(prices: emptyPrices, period: 3)
        XCTAssertTrue(emptyResult.isEmpty, "空数组的结果应该是空数组")
        
        // 测试数组长度小于周期
        let shortPrices = [1.0, 2.0]
        let shortResult = DataUtil.calculateMA(prices: shortPrices, period: 5)
        XCTAssertEqual(shortResult.count, 2)
        XCTAssertNil(shortResult[0])
        XCTAssertNil(shortResult[1])
    }
}
