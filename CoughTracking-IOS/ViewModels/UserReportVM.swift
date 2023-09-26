//
//  UserReportVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 03/10/2023.
//

import Foundation


class UserReportVM:ObservableObject{
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isDeleted = false
    
    @Published var errorMessage = ""
    
    @Published var userData = LoginResult()
    
    
    func requestForReport(){
        
        isLoading = true
        
        
//        ApiClient.shared.
        
    }
    
}
