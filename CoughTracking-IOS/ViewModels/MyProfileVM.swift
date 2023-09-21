//
//  MyProfileVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 20/09/2023.
//

import Foundation
import UIKit

class MyProfileVM:ObservableObject{
    
    @Published var selectedImage:UIImage? = nil
    @Published var userData = MyUserDefaults.getUserData() ?? LoginResult()
    @Published var userImageUrl = MyUserDefaults.getString(forKey: Constants.image)
    
    @Published var isEditAble = false
    @Published var showChoseSheet = false
    @Published var isUpdated = false
    
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    
    
    func updateProfile(){
        
        
        isLoading = true
        
        
        var image:UIImage? = selectedImage
        
        if(selectedImage==nil && userImageUrl.isEmpty){
            
            image = UIImage(systemName: "person.fill")
            
        }
        
        ApiClient.shared.updateProfile(name: userData.name,image: image) { [self] response in
            
            isLoading = false
            
            
            switch response {
            case .success(let success):
                
                if(success.name==nil && success.url == nil){
                    
                    isUpdated = false
                    isError = true
                    errorMessage = "Error while uploding image, Please try again"
                    
                }else{
                    
                    //Updated In Successfully
                    MyUserDefaults.saveUserData(value: userData)
                    MyUserDefaults.saveString(forKey: Constants.image, value: success.url ?? "")
                    
                    isError = false
                    isUpdated = true
                }
                
                break
                
            case .failure(let failure):
                isUpdated = false
                isError = true
                errorMessage = failure.detail[0].msg ?? ""
                break
                
            }
            
            
        }
        
        
    }
    
}
