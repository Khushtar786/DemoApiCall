//
//  DictionaryExtensions.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func getString(forKey key: Key, pointValue val: Int = 0, defaultValue def: String = "") -> String {
        if let str = self[key] as? String {
            return str
        } else if let num = self[key] as? NSNumber {
            let doubleVal = Double(truncating: num)
            return String(format: "%0.\(val)f", doubleVal)
        }
        return def
    }
    
    func getFloat(forKey key: Key, defaultValue def: Float = 0.0) -> Float {
        if let num = self[key] as? Float {
            return num
        } else if let str = self[key] as? String {
            if let val = Float(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Float(truncating: num)
        }
        return def
    }
    
    func getDouble(forKey key: Key, defaultValue def: Double = 0.0) -> Double {
        if let num = self[key] as? Double {
            return num
        } else if let str = self[key] as? String {
            if let val = Double(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Double(truncating: num)
        }
        return def
    }
    
    func getInt(forKey key: Key, defaultValue def: Int = 0) -> Int {
        if let num = self[key] as? Int {
            return num
        } else if let str = self[key] as? String {
            if let val = Int(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Int(truncating: num)
        }
        return def
    }
    
    func getBool(forKey key: Key, defaultValue def: Bool = false) -> Bool {
        if let val = self[key] as? Bool {
            return val
        } else if let num = self[key] as? NSNumber {
            if num == 0 {
                return false
            } else if num == 1 {
                return true
            }
        } else if let str = self[key] as? String {
            if str.lowercased() == "true" || str.lowercased() == "yes" {
                return true
            } else if str.lowercased() == "false" || str.lowercased() == "no" {
                return false
            }
        }
        return def
    }
    
    func getArray(forKey key: Key, components separatedBy: String? = nil, defaultValue def: Array<Any> = []) -> Array<Any> {
        if let arr = self[key] as? Array<Any> {
            return arr
        } else if let str = self[key] as? String {
            if let separated = separatedBy {
                return str.components(separatedBy: separated)
            }
        }
        return def
    }
    
    func getDictionay(forKey key: Key, defaultValue def: Dictionary = [:]) -> Dictionary {
        if let dict = self[key] as? Dictionary {
            return dict
        } else if let str = self[key] as? String {
            if let data = str.data(using: .utf8) {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    if let dict = jsonObject as? Dictionary {
                        return dict
                    }
                }
            }
        }
        return def
    }
    
    mutating func removeNullValues() {
        for (key, value) in self where value is NSNull {
            self[key] = "" as? Value
        }
    }
    
}
