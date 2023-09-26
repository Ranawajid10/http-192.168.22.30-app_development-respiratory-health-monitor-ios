//
//  ProfileSettingsVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 03/10/2023.
//

import Foundation

class ProfileSettingsVM:ObservableObject{
    
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isDeleted = false
    
    @Published var errorMessage = ""
    
    @Published var userData = LoginResult()
    
    func deleteAccount(){
        
        
        isLoading = true
        
        ApiClient.shared.deleteAccount(token: userData.token ?? "") { [self] response in
            
            isLoading = false
            switch response {
            case .success(let success):
                
                if(success.statusCode==nil && success.detail != nil){
                    
                    isError = true
                    errorMessage = success.detail ?? ""
                    
                }else if(success.statusCode == 201 || success.statusCode == 200){
                    
                    isDeleted = true
                    
                }
                
                break
            case .failure(let failure):
                errorMessage = failure.localizedDescription
                isError = true
            }
            
            
        }
        
        
    }
    
}
