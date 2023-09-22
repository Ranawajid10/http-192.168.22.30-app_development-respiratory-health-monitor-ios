//
//  ApiClient.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation
import Alamofire
import UIKit

class ApiClient {
    
    static let shared = ApiClient()
    let baseUrl = "https://coughdairy.ai4lyf.com/"
    
    var simpleHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    var tokenHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer \(MyUserDefaults.getBearerToken())"
    ]
    
    
    func sendOTP(email:String,fcm:String, completion: @escaping (Result<SendOtpResult, ErrorResult>) -> Void){
        
        let url = baseUrl + "user/otp"
        
        let params = [
            "email": email,
            "guid" : fcm ]
        
        
        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: simpleHeaders)
            .responseDecodable(of:SendOtpResult.self){ response in
                
                switch response.result{
                    
                case.success(let data):
                    completion(.success(data))
                    break
                case.failure(let error):
                    
                    var apiError = ApiError()
                    apiError.msg = error.localizedDescription
                    
                    var errorResult = ErrorResult()
                    errorResult.detail = [apiError]
                    
                    completion(.failure(errorResult))
                    break
                    
                }
                
                
            }
        
    }
    
    func login(email:String,otp:Int, completion: @escaping (Result<LoginResult, ErrorResult>) -> Void){
        
        let url = baseUrl + "user/login"
        
        let params = [
            "email": email,
            "otp" : otp ] as [String : Any]
        
        
        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: simpleHeaders)
            .responseDecodable(of:LoginResult.self){ response in
                
                switch response.result{
                    
                case.success(let data):
                    completion(.success(data))
                    break
                case.failure(let error):
                    
                    var apiError = ApiError()
                    apiError.msg = error.localizedDescription
                    
                    var errorResult = ErrorResult()
                    errorResult.detail = [apiError]
                    
                    completion(.failure(errorResult))
                    break
                    
                }
                
                
            }
        
    }
    
    
    func addVolunteerInfo(age:String,gender:String,ethnicity:String,medicalCondition:String, completion: @escaping (Result<SendOtpResult, ErrorResult>) -> Void){
        
        let url = baseUrl + "donate/info"
        
        let params = [
            "age": Int(age) ?? 0,
            "gender": gender,
            "ethnicity": ethnicity,
            "medical_condition" : medicalCondition
        ] as [String : Any]
        
        
        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: tokenHeaders)
            .responseDecodable(of:SendOtpResult.self){ response in
                
                switch response.result{
                    
                case.success(let data):
                    completion(.success(data))
                    break
                case.failure(let error):
                    
                    var apiError = ApiError()
                    apiError.msg = error.localizedDescription
                    
                    var errorResult = ErrorResult()
                    errorResult.detail = [apiError]
                    
                    completion(.failure(errorResult))
                    break
                    
                }
                
                
            }
        
    }
    
    
    func updateProfile(name:String,image:UIImage? = nil, completion: @escaping (Result<EditProfileResult, ErrorResult>) -> Void){
        
        let url = baseUrl + "info/profile"
        
        var params = [
            "name": name
        ] as [String : Any]
        
        // Add image data to params if available
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.5) {
            params["file"] = imageData
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                } else if let imageData = value as? Data {
                    multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
                }
            }
        }, to: url, headers: tokenHeaders).responseDecodable(of:EditProfileResult.self){ response in
            
            switch response.result{
                
            case.success(let data):
                completion(.success(data))
                break
            case.failure(let error):
                
                var apiError = ApiError()
                apiError.msg = error.localizedDescription
                
                var errorResult = ErrorResult()
                errorResult.detail = [apiError]
                
                completion(.failure(errorResult))
                break
                
            }
            
        }
        
        
    }
    
    
    func uploadSamples(allCoughList:[VolunteerCough], completion: @escaping (Result<Int, ErrorResult>) -> Void){
        
        let url = baseUrl + "donate/recording"
        
        AF.upload(multipartFormData: { multipartFormData in
            for i in 0..<allCoughList.count {
                
                
                let cough = allCoughList[i]
                
                let fileName = "\(i+1)_dry_\(cough.coughPower ?? "moderate")_\(DateUtills.getCurrentTimeInMilliseconds()).wav"
                
                print("uploadSamples",fileName)
                
                if let coughData = cough.coughSegments{
                   
                    do{
                        
                        let file = try Functions.saveWAVFileToDocumentsDirectory(floatArray: coughData, sampleRate: 22050, fileName: fileName)
                        print("file",file)
                        multipartFormData.append(file, withName: "files", fileName: fileName, mimeType: "audio/wav")
                      
                        
                    }catch{
                        
                        print("error",error.localizedDescription)
                        
                    }
                   
                }
            }
        }, to: url, headers: tokenHeaders)
        .responseDecodable(of:Int.self){ response in

            switch response.result{

            case.success(let data):
                completion(.success(data))
                break
            case.failure(let error):

                var apiError = ApiError()
                apiError.msg = error.localizedDescription

                var errorResult = ErrorResult()
                errorResult.detail = [apiError]

                completion(.failure(errorResult))
                break

            }

        }
        
    }
    
    
    func socialLogin(loginWith:String,email:String,idToken:String,fcmToken:String, completion: @escaping (Result<Int, ErrorResult>) -> Void){
     
        
        let url = baseUrl + "user/social/login"
        
        let params = [
            "type_": loginWith,
            "id_token": idToken,
            "email": email,
            "guid" : fcmToken
        ] as [String : Any]
        
        
        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: simpleHeaders)
            .responseJSON{ response in
                
                print("dadad",response,"-----",params)
                
//                switch response.result{
//
//                case.success(let data):
//                    completion(.success(data))
//                    break
//                case.failure(let error):
//
//                    var apiError = ApiError()
//                    apiError.msg = error.localizedDescription
//
//                    var errorResult = ErrorResult()
//                    errorResult.detail = [apiError]
//
//                    completion(.failure(errorResult))
//                    break
//
//                }
//
                
            }
        
        
        
    }
    
}
