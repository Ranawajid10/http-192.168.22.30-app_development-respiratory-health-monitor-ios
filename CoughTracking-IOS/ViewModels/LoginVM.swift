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
//    @Published var email: String = ""
        @Published var email: String = "aftababbas7866@gmail.com"
    @Published var errorMessage: String = ""
    
    @Published var isLoading = false
    @Published var isError = false
    
    @Published var showNoInternetAlert = false
    @Published var navigateToOTP = false
    
    @Published var loginWith = ""
    @Published var idToken = ""
    
    
    
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
                    
                    email = userProfile.email
                    
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
        
        print("rer")
        
        let provider = OAuthProvider(providerID: "twitter.com")
        
        provider.customParameters = [
            "lang": "en"
        ]
        
        
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                // Handle error.
                print("rerr",error?.localizedDescription)
            }
            if credential != nil {
//                Auth.auth().signIn(with: credential) { authResult, error in
//                    if error != nil {
//                        // Handle error.
//                    }
//                    // User is signed in.
//                    // IdP data available in authResult.additionalUserInfo.profile.
//                    // Twitter OAuth access token can also be retrieved by:
//                    // (authResult.credential as? OAuthCredential)?.accessToken
//                    // Twitter OAuth ID token can be retrieved by calling:
//                    // (authResult.credential as? OAuthCredential)?.idToken
//                    // Twitter OAuth secret can be retrieved by calling:
//                    // (authResult.credential as? OAuthCredential)?.secret
//                }
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
        
        
        
        ApiClient.shared.socialLogin(loginWith:loginWith,email:email,idToken:idToken,fcmToken:fcmToken){ response in
            
            
        }
        
        
    }
    
}
