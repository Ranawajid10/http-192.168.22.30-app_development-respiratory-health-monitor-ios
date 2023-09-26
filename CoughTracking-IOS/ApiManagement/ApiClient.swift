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
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(MyUserDefaults.getBearerToken())"
        ]
        
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
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(MyUserDefaults.getBearerToken())"
        ]
        
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
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(MyUserDefaults.getBearerToken())"
        ]
        
        
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
    
    
    func socialLogin(loginWith:String,email:String,idToken:String,fcmToken:String, completion: @escaping (Result<LoginResult, ErrorResult>) -> Void){
        
        
        let url = baseUrl + "user/social/login"
        
        let params = [
            "type_": loginWith,
            "id_token": idToken,
            "email": email
        ] as [String : Any]
        
        
        AF.request(url,method: .post,parameters: params,encoding: JSONEncoding.default,headers: simpleHeaders)
        
            .responseDecodable(of: LoginResult.self){ response in
                
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
    
    
    func getStats(filterBy:String,date:String,filterSlot:String,isDailyCurrent:Bool,token:String, completion:@escaping (Result<StatsResult,ErrorResult>)->Void){
        
        let path =  "portal/cough/rec_intensity"
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        
        var urlComponents = URLComponents(string: baseUrl + path)!
        urlComponents.queryItems = [URLQueryItem(name: "filter_by", value: filterBy)]
        
        if(isDailyCurrent){
            
            // Add more query parameters
            let additionalParam1 = URLQueryItem(name: "value", value: date)
            urlComponents.queryItems?.append(additionalParam1)
            
            let additionalParam2 = URLQueryItem(name: "filterSlot", value: filterSlot)
            urlComponents.queryItems?.append(additionalParam2)
            
        }
        
        // If you have additional query parameters, add them like this:
        // urlComponents.queryItems?.append(URLQueryItem(name: "value", value: date))
        
        let url =  urlComponents
        
        
        //        var params:[String:String] = [:]
        //
        //
        //
        //        if(filterBy==Constants.daily && isDailyCurrent){
        //
        //            params = [
        //                "filter_by": filterBy
        //            ]
        //
        //        }else{
        //
        //            params = [
        //                "filter_by": filterBy,
        //                "value": date,
        //                "filterSlot": filterSlot
        //            ]
        //
        //        }
        
        //        print("DailyCoughsView",params)
        
        
        AF.request(url,method: .get,encoding: JSONEncoding.default,headers: tokenHeaders)
        //            .responseJSON { response in
        //                print("HourlyCoughVM","url",response)
        //            }
            .responseDecodable(of:StatsResult.self){ response in
                
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
    
    func newUploadCoughSamplesStats(allCoughList:[VolunteerCough],stats:String,token:String, completion: @escaping (Result<Int, ErrorResult>) -> Void){
        
        let url = baseUrl + "donate/recording/v2"
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters = [
            
            "stats_track": stats
            
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            for i in 0..<allCoughList.count {
                
                
                let cough = allCoughList[i]
                
                let date = cough.date ?? ""
                let time = cough.time ?? ""
                
                let finalDate = date + "-" + time
                
                
                print("finalDate",finalDate)
                
                let timeStamp = DateUtills.dateToMilliseconds(dateString:finalDate,format: DateTimeFormats.dateTimeFormat3) ?? 0
                
                let fileName = "\(i+1)_dry_\(cough.coughPower ?? "moderate")_\(String(timeStamp)).wav"
                
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
    
    func deleteAccount( token:String,completion: @escaping (Result<DeleteAccount, ErrorResult>) -> Void){
        
        
        let url = baseUrl + "user/delete"
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        
        AF.request(url,method: .post,encoding: JSONEncoding.default,headers: tokenHeaders)
            .responseDecodable(of: DeleteAccount.self){ response in
                
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
    
    
    func requestUserReport( token:String,completion: @escaping (Result<DeleteAccount, ErrorResult>) -> Void){
        
        
        let url = baseUrl + "report/generate_report"
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        
        AF.request(url,method: .post,encoding: JSONEncoding.default,headers: tokenHeaders)
        
            .responseDecodable(of: DeleteAccount.self){ response in
                
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
    
    func getCoughRecordings( token:String,date:String,completion: @escaping (Result<[CoughRecordingsResult], ErrorResult>) -> Void){
        
        let path =  "donate/get"
        
        var urlComponents = URLComponents(string: baseUrl + path)!
        urlComponents.queryItems = [URLQueryItem(name: "date_", value: date)]
        
       
        let url =  urlComponents
       
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        
        AF.request(url,method: .get,encoding: JSONEncoding.default,headers: tokenHeaders)
            .responseDecodable(of: [CoughRecordingsResult].self){ response in
                
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
    
    
    func uploadNotes(allNotesList:[UploadNotes],token:String, completion: @escaping (Result<NotesUploadResult, ErrorResult>) -> Void){
        
        let urlString = baseUrl + "notes/add"
        
        let tokenHeaders: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        let url = URL(string: urlString)
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: allNotesList, options: [])
            
            
            let uploadRequest = RawDataUploadRequest(url: url!, method: .post, data: jsonData, headers: tokenHeaders)
            
            
            
            AF.request(uploadRequest)
                .responseDecodable(of:NotesUploadResult.self){ response in
                    
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
            
        }catch {
            // Handle JSON serialization error
            print("JSON serialization error: \(error)")
        }
        
    }
   
}

struct RawDataUploadRequest: URLRequestConvertible {
    let url: URL
    let method: HTTPMethod
    let data: Data
    let headers: HTTPHeaders?

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.headers = headers!
        urlRequest.httpBody = data
        return urlRequest
    }
}
