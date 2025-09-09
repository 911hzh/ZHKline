//
//  ApiClient.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation

/// 网络请求错误类型
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

/// 网络请求基类
class ApiClient {
    private let baseUrl: String
    private let session: URLSession
    
    /// 初始化网络请求客户端
    /// - Parameter baseUrl: 基础URL
    init(baseUrl: String, session: URLSession = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
    /// GET请求
    /// - Parameter path: 请求路径
    /// - Returns: 响应数据和URLResponse
    public func get(path: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: baseUrl + path) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
            }
            
            return (data, response)
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
    
    /// 泛型GET请求，自动解析JSON
    /// - Parameters:
    ///   - path: 请求路径
    ///   - responseType: 响应数据类型
    /// - Returns: 解析后的数据模型
    public func get<T: Codable>(path: String, responseType: T.Type) async throws -> T {
        let (data, _) = try await get(path: path)
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
