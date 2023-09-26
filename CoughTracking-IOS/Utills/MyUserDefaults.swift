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
        UserDefaults.standard.synchronize()
    }
    
    static func getString(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    // MARK: - Integer
    
    static func saveInt( forKey key: String,value: Int) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func getInt(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // MARK: - Boolean
    
    static func saveBool(forKey key: String,value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func getBool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // MARK: - Remove
    
    static func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    // MARK: - Float
    
    static func saveFloat( forKey key: String,value: Float) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func getFloat(forKey key: String) -> Float {
        return UserDefaults.standard.float(forKey: key)
    }
    
    // MARK: - User Data
    
    static func saveUserData<LoginResult: Codable>(value: LoginResult) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(value)
            UserDefaults.standard.set(encodedData, forKey: Constants.userData)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving Codable object: \(error.localizedDescription)")
        }
    }
    
    static func getUserData<LoginResult: Codable>() -> LoginResult? {
        if let encodedData = UserDefaults.standard.data(forKey: Constants.userData) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(LoginResult.self, from: encodedData)
            } catch {
                print("Error retrieving Codable object: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    // MARK: - Remove User Data
    
    static func removeUserData() {
        UserDefaults.standard.removeObject(forKey: Constants.userData)
        UserDefaults.standard.synchronize()
    }
    
    
    // MARK: - Get Bearer Yoken
    
    static func getBearerToken() -> String {
        
        let userData = getUserData() ?? LoginResult()
        return userData.token ?? ""
    }
    
    static func saveDate(forKey key: String, value: Date) {
           UserDefaults.standard.set(value, forKey: key)
           UserDefaults.standard.synchronize()
       }

       static func getDate(forKey key: String) -> Date? {
           return UserDefaults.standard.object(forKey: key) as? Date
       }
    
    
    static func removeDate(key:String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
