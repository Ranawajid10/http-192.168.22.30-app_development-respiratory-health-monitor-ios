//
//  LoginVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

class LoginVM:ObservableObject{
    
    
    @Published var fcmToken: String  = "dL6uAbzuRMutCimTmYq4v9:APA91bGu0MnuzDhpzR-EXyjjlD0OzUuR6i_t8CO1J8Jpi-FQzevV77qCn1Xn9yufLcUaNJ4vsHVzLjANoazk-dq3HmRaJMtfPe_702HeTLXJxnuX-dO5WyOynGSeBVkLFJAmn7LsvRO"
    @Published var email: String = ""
    @Published var socialEmail: String = ""
    //        @Published var email: String = "aftababbas7866@gmail.com"
//            @Published var email: String = "sicemep313@htoal.com"
    @Published var errorMessage: String = ""
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isSocialLoggedIn = false
    @Published var underDev = false
    
    @Published var showNoInternetAlert = false
    @Published var navigateToOTP = false
    
    @Published var loginWith = ""
    @Published var idToken = ""
    
    let provider = OAuthProvider(providerID: "twitter.com")
    
    
    
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
        
        if (Connectivity.isConnectedToInternet){
            
            if(logintype==Constants.google){
                
                googeSignIn()
                
            }else if(logintype==Constants.facebook){
                
                initializedFB()
                
            }else if(logintype==Constants.twitter){
                
                twitterlogin()
                
            }else{
                
                let e = email
                
                if(email.isEmpty || email == ""){
                    
                    isError = true
                    errorMessage = "Please enter email!"
                    
                }else if(!Functions.isValidEmail(e)){
                    
                    isError = true
                    errorMessage = "Please enter valid email!"
                    
                }else{
                    
                    
                    MyUserDefaults.saveString(forKey:Constants.loginWith, value: loginWith)
                    navigateToOTP = true
                    
                }
            }
        }else{
            
            showNoInternetAlert = true
            
        }
        
    }
    
    func googeSignIn(){
        
        isLoading = true
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [self] result, error in
            
            
            
            if let error = error {
                
                isLoading = false
                errorMessage = error.localizedDescription
                isError = true
                
                return
            }
            
            
            if let userData = result?.user {
                
                // Get User Token Id if available else return
                if let userIdToken = userData.idToken{
                    
                    idToken = userIdToken.tokenString
                    
                    
                }else{
                    
                    isLoading = false
                    errorMessage = "No user data found, Please try again!"
                    isError = true
                    return
                }
                
                
                // Get User email if available else return
                if let userProfile = userData.profile{
                    
                    socialEmail = userProfile.email
                    
                }else{
                    
                    isLoading = false
                    errorMessage = "No user data found, Please try again!"
                    isError = true
                    return
                    
                }
                
                
                
                //Here you have email and Token Id call Social Login Api
                doSocialLogin()
                
            }else{
                
                isLoading = false
                errorMessage = "No data found, Please try again!"
                isError = true
                
            }
            
            
        }
        
    }
    
    func initializedFB(){
        
        
        
    }
    
    
    func twitterlogin(){
        
        isLoading = true
        
        provider.getCredentialWith(nil) { [self] credential, error in
            
            
            if error != nil {
                errorMessage  = error?.localizedDescription ?? ""
                isError = true
            }
            
            
            if let credential = credential {
                Auth.auth().signIn(with: credential) { [self] authResult, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        isError = true
                        return;
                    }
                    
                    let currentUser = Auth.auth().currentUser
                    currentUser?.getIDTokenForcingRefresh(true) { [self] idToken, error in
                      if let error = error {
                          errorMessage = error.localizedDescription
                          isError = true
                        return;
                      }
                        
                        if let idToken = idToken {
                            
                            self.idToken = idToken
                            self.email = currentUser?.email ?? ""
                            
                            print("idToken",idToken,"----email",self.email)
                            
                            self.doSocialLogin()
                            
                        }else{
                            
                            errorMessage = "Faild to get token, Please try again"
                            isError = true
                            
                        }
                    }
                    
                }
            }
        }
        
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
    
    func doSocialLogin(){
        
        ApiClient.shared.socialLogin(loginWith:loginWith,email:socialEmail,idToken:idToken,fcmToken:fcmToken){ [self] response in
            
            isLoading = false
            
            switch response {
            case .success(let success):
                
                if(success.statusCode==nil && (success.token != nil) && !(success.detail != nil)){
                    
                    isError = true
                    errorMessage = success.detail ?? ""
                    
                }else if(success.statusCode == 201 || success.statusCode == 200){
                    
                    
                    
                    MyUserDefaults.saveUserData(value: success)
                    MyUserDefaults.saveBool(forKey:Constants.isLoggedIn, value: true)
                    MyUserDefaults.saveBool(forKey:Constants.isBaseLineSet, value: false)
                    MyUserDefaults.saveBool(forKey:Constants.isAllowSync, value: false)
                    MyUserDefaults.saveString(forKey:Constants.loginWith, value: loginWith)
                    
                    isSocialLoggedIn = true
                    
                }
                
            case .failure(let failure):
                errorMessage = failure.localizedDescription
                isError =  true
            }
            
        }
        
        
    }
    
}
