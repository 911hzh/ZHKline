//
//  KlineApi.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation

/// K线周期枚举
enum KLinePeriod: String, CaseIterable {
    case min15 = "15min"
    case min60 = "60min"
    case hour4 = "4hour"
    case day1 = "1day"
    case mon1 = "1mon"
}

/// K线API接口类
class KlineApi {
    static let shared = KlineApi()
    private let apiClient: ApiClient
    
    /// 初始化K线API
    /// - Parameter apiClient: API客户端实例
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    /// 便利初始化方法
    /// - Parameter baseUrl: 基础URL，默认为火币API
    convenience init(baseUrl: String = "https://api.huobi.pro") {
        let client = ApiClient(baseUrl: baseUrl)
        self.init(apiClient: client)
    }
    
    /// 获取K线历史数据
    /// - Parameters:
    ///   - symbol: 交易对符号（如："btcusdt"）
    ///   - period: K线周期
    ///   - size: 获取数量，最大2000
    /// - Returns: K线响应数据
    func getKLineHistory(symbol: String, period: KLinePeriod, size: Int = 200) async throws -> KLineResponse {
        let path = "/market/history/kline?period=\(period.rawValue)&size=\(size)&symbol=\(symbol)"
        return try await apiClient.get(path: path, responseType: KLineResponse.self)
    }
    
    /// 获取K线历史数据并转换为KLineModel数组
    /// - Parameters:
    ///   - symbol: 交易对符号（如："btcusdt"）
    ///   - period: K线周期
    ///   - size: 获取数量，最大2000
    /// - Returns: KLineModel数组
    func getKLineModels(symbol: String, period: KLinePeriod, size: Int = 200) async throws -> [KLineData] {
        let response = try await getKLineHistory(symbol: symbol, period: period, size: size)
        return response.data
    }
    
    /// 泛型接口：获取指定类型的数据
    /// - Parameters:
    ///   - path: API路径
    ///   - responseType: 期望的响应数据类型
    /// - Returns: 指定类型的数据
    func fetchData<T: Codable>(path: String, responseType: T.Type) async throws -> T {
        return try await apiClient.get(path: path, responseType: responseType)
    }
    
    /// 泛型接口：根据参数构建请求获取数据
    /// - Parameters:
    ///   - endpoint: API端点
    ///   - parameters: 请求参数
    ///   - responseType: 期望的响应数据类型
    /// - Returns: 指定类型的数据
    func fetchData<T: Codable>(endpoint: String, parameters: [String: String] = [:], responseType: T.Type) async throws -> T {
        var path = endpoint
        
        if !parameters.isEmpty {
            let queryItems = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            path += "?\(queryItems)"
        }
        
        return try await apiClient.get(path: path, responseType: responseType)
    }
}

/// KlineApi 扩展 - 提供更多便利方法
extension KlineApi {
    
    /// 获取实时K线数据
    /// - Parameters:
    ///   - symbol: 交易对符号
    ///   - period: K线周期
    /// - Returns: 最新的K线数据
    func getLatestKLine(symbol: String, period: KLinePeriod) async throws -> KLineData? {
        let models = try await getKLineModels(symbol: symbol, period: period, size: 1)
        return models.first
    }
    
    /// 批量获取多个交易对的K线数据
    /// - Parameters:
    ///   - symbols: 交易对符号数组
    ///   - period: K线周期
    ///   - size: 每个交易对的数据量
    /// - Returns: 以交易对为键的K线数据字典
    func getBatchKLineData(symbols: [String], period: KLinePeriod, size: Int = 200) async throws -> [String: [KLineData]] {
        var result: [String: [KLineData]] = [:]
        
        // 使用 TaskGroup 并发获取数据
        try await withThrowingTaskGroup(of: (String, [KLineData]).self) { group in
            for symbol in symbols {
                group.addTask {
                    let models = try await self.getKLineModels(symbol: symbol, period: period, size: size)
                    return (symbol, models)
                }
            }
            
            for try await (symbol, models) in group {
                result[symbol] = models
            }
        }
        
        return result
    }
}
