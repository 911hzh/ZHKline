//
//  ColorExtension.swift
//  ZHKLine
//
//  Created by huang on 2025/8/28.
//

import Foundation
import UIKit
// MARK: - UIColor Extension for Hex Colors
extension UIColor {
    
    /// 通过十六进制字符串创建UIColor
    /// - Parameter hexString: 十六进制颜色字符串，支持格式：#RRGGBB, #RRGGBBAA, RRGGBB, RRGGBBAA
    /// - Returns: UIColor实例，如果解析失败则返回clear颜色
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    /// 通过十六进制字符串创建UIColor（静态方法）
    /// - Parameter hexString: 十六进制颜色字符串
    /// - Returns: UIColor实例
    static func hex(_ hexString: String) -> UIColor {
        return UIColor(hexString: hexString)
    }
    
    /// 通过十六进制整数值创建UIColor
    /// - Parameters:
    ///   - hex: 十六进制整数值 (例如: 0xFF0000 表示红色)
    ///   - alpha: 透明度 (0.0-1.0)
    /// - Returns: UIColor实例
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    /// 通过十六进制整数值创建UIColor（静态方法）
    /// - Parameters:
    ///   - hex: 十六进制整数值
    ///   - alpha: 透明度
    /// - Returns: UIColor实例
    static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
    
    /// 将UIColor转换为十六进制字符串
    /// - Parameter includeAlpha: 是否包含透明度信息
    /// - Returns: 十六进制颜色字符串
    func toHexString(includeAlpha: Bool = false) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        if includeAlpha {
            let rgba: Int = (Int)(a*255)<<24 | rgb
            return String(format: "#%08X", rgba)
        } else {
            return String(format: "#%06X", rgb)
        }
    }
}
