//
//  ApiClient.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation
import Alamofire

class ApiClient {
    
    static let shared = ApiClient()
    let baseUrl = "https://coughdairy.ai4lyf.com/"
    
    var headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
    
    
    
    func sendOTP(email:String,fcm:String, completion: @escaping (Result<SendOtpResult, ErrorResult>) -> Void){
        
        let url = baseUrl + "user/otp"
        
        let params = [
            "email": email,
            "guid" : fcm ]
        

        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: headers)
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
        

        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: headers)
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
        

        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: headers)
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
    
    //    func loginWithEmailPwd(email:String,pwd:String, completion: @escaping(Result<String,ErrorResult>) -> Void){
    //
    //        let url = baseUrl + "user/login"
    //
    ////        AF.request(<#T##convertible: URLConvertible##URLConvertible#>)
    //
    //
    //    }
    
    
    
    
}
