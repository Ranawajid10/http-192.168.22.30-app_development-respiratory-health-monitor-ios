//
//  MyUserDefaults.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation


class MyUserDefaults{
    
    // MARK: - String
    
    static func saveString(forKey key: String, value: String ) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func getString(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    // MARK: - Integer
    
    static func saveInt( forKey key: String,value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func getInt(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // MARK: - Boolean
    
    static func saveBool(forKey key: String,value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func getBool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // MARK: - Remove
    
    static func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    
    // MARK: - Float
    
    static func saveFloat( forKey key: String,value: Float) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func getFloat(forKey key: String) -> Float {
        return UserDefaults.standard.float(forKey: key)
    }
    
}
