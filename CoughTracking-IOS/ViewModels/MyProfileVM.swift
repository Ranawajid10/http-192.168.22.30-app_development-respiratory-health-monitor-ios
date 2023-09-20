//
//  MyProfileVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 20/09/2023.
//

import Foundation


class MyProfileVM:ObservableObject{
    
    
    @Published var userData = MyUserDefaults.getUserData() ?? LoginResult()
    
    @Published var isEditAble = false
    
    
    @Published var isLoading = false
    
   
    
    func updateProfile(){
        
        
        isLoading = true
        
        ApiClient.shared.updateProfile(name: userData.name) { [self] response in
            
            isLoading = false
            
            
        }
        
        
    }
    
}
