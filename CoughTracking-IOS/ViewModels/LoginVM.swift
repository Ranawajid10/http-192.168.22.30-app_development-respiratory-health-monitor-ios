//
//  LoginVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation
import Firebase

class LoginVM:ObservableObject{
    
    @Published var networkManager: NetworkManager
    
    @Published var fcmToken: String = ""
//        @Published var email: String = ""
    @Published var email: String = "aftababbas7866@gmail.com"
    @Published var errorMessage: String = ""
    
    @Published var isLoading = false
    @Published var isError = false
    
    @Published var showNoInternetAlert = false
    @Published var navigateToOTP = false
    
    @Published var loginWith = ""
    
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func checkLogin(){
        
        
        switch(loginWith){
            
        case Constants.google:
            checkConnection(logintype: Constants.google)
            break
        case Constants.facebook:
            checkConnection(logintype: Constants.facebook)
            break
        case Constants.twitter:
            checkConnection(logintype: Constants.twitter)
            break
        case Constants.simple:
            checkConnection(logintype: Constants.simple)
            break
            
        default:
            checkConnection(logintype: Constants.simple)
            
        }
        
        
    }
    
    
    private func checkConnection(logintype:String){
        
        if (networkManager.isInternetAvailable){
            
            if(logintype==Constants.google){
                
                googeSignIn()
                
            }else if(logintype==Constants.facebook){
                
                initializedFB()
                
            }else if(logintype==Constants.twitter){
                
                twitterlogin()
                
            }else{
                
                if(email.isEmpty){
                    
                    isError = true
                    errorMessage = "Please enter email!"
                    
                }else if(!Functions.isValidEmail(email)){
                    
                    isError = true
                    errorMessage = "Please enter valid email!"
                    
                }else{
                    
                    getToken()
                    
                }
            }
        }else{
            
            showNoInternetAlert = false
            
        }
        
    }
    
    func googeSignIn(){
        
        
        
    }
    
    func initializedFB(){
        
        
        
    }
    
    
    func twitterlogin(){
        
        
        
    }
    
    func getToken(){
        
        //
        //        Messaging.messaging().token { [self] token, error in
        //                   if let error = error {
        //                       print("Error fetching FCM token: \(error)")
        //                   } else if let token = token {
        //
        //                       print("FCM Token: \(token)")
        
        fcmToken = "dL6uAbzuRMutCimTmYq4v9:APA91bGu0MnuzDhpzR-EXyjjlD0OzUuR6i_t8CO1J8Jpi-FQzevV77qCn1Xn9yufLcUaNJ4vsHVzLjANoazk-dq3HmRaJMtfPe_702HeTLXJxnuX-dO5WyOynGSeBVkLFJAmn7LsvRO"
        navigateToOTP = true
        
        //                   }
        //               }
        //
        
        
    }
    
}
