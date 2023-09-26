//
//  LoginView.swift
//  CoughTracking-IOS
//
//  Created by ai4lyf on 11/08/2023.
//

import SwiftUI

struct LoginView: View
{
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var loginVM = LoginVM()
    
    @State private var toast: FancyToast? = nil
    
    
    @State private var allValunteerCoughList: [VolunteerCough] = []
    @State private var uploadTrackingHoursList: [HoursUpload] = []

    
    
    var body: some View {
        ZStack{
            
            ScrollView(showsIndicators: false){
                VStack(spacing: 20) {
                    Image("logosmall")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .alignmentGuide(.top) { dimension in
                            dimension[.top]
                        }
                    
                    Image("welcome_login_text")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 130)
                        .padding(.top, 30)
                    
                    TextField("Enter email", text: $loginVM.email)
                        .keyboardType(.emailAddress)
                        .padding(.leading, 10)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.grayBorder, lineWidth: 1)
                                .background(Color.white)
                        )
                        .cornerRadius(10)
                    
                    
                    
                    Button{
                        
                        loginVM.loginWith = Constants.simple
                        loginVM.checkLogin()
                        
                    } label: {
                        
                        Image("proceed_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                        
                        
                    }
                    .padding(.top, 30)
                    
                    Image("or_proceed_with_text")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height:40)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        
                        Button(action: {
                            
                            loginVM.loginWith = Constants.google
                            loginVM.checkLogin()
                            
                        }) {
                            Image("google_img")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height:40)
                        }
                        
                        Button(action: {
                            
                            loginVM.underDev.toggle()
//                            loginVM.loginWith = Constants.facebook
//                            loginVM.checkLogin()
                            
                        }) {
                            Image("facebook_img")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height:40)
                        }
                        
                        Button {
                            
                            loginVM.loginWith = Constants.twitter
                            loginVM.checkLogin()
                            
                        } label: {
                            Image("twitter_img")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height:40)
                        }
                        
                        
                    }
                    
                    Spacer()
                    
                }
                .padding()
            }
            
            
            if(loginVM.isLoading){
                
                LoadingView()
                
            }
            
        }.navigationTitle("")
        .toastView(toast: $toast)
        .dismissKeyboardOnTap()
            .environment(\.managedObjectContext,viewContext)
            .navigationDestination(isPresented: $loginVM.navigateToOTP, destination: {
                
                SendOtpView(email: loginVM.email, fcmToken: loginVM.fcmToken, loginWith: loginVM.loginWith)
                    .environment(\.managedObjectContext,viewContext)
                
            })
            .navigationDestination(isPresented: $loginVM.isSocialLoggedIn, destination: {
                
                AllowSyncStatsView(text: "Continue",allValunteerCoughList: $allValunteerCoughList ,uploadTrackingHoursList: $uploadTrackingHoursList)
                    .environment(\.managedObjectContext,viewContext)
                
            })
            .background(Color.screenBG)
            .onReceive(loginVM.$isError, perform: { i in
                
                if(i){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: loginVM.errorMessage)
                    loginVM.isError = false
                    
                }
                
            })
            .onReceive(loginVM.$isSocialLoggedIn, perform: { i in
                
                if(i){
                    
                    
                    
                }
                
            })
            .customAlert(isPresented: $loginVM.showNoInternetAlert) {
                
                NoInternetAlertView{
                    
                    loginVM.checkLogin()
                    
                }
                
            }.customAlert(isPresented: $loginVM.underDev) {
                
                CustomAlertView(
                    showVariable: $loginVM.underDev, showTwoButton: false, message: "Feature Under Development",
                    action: {
                        print("Okay Clicked")
                    }
                )
                
            }
            
    }
    
    
    
    func loginWithFacebook()
    {
        print("Facebook")
        // Implement Facebook login logic using the Facebook SDK
        // Example: Use LoginManager to initiate Facebook login flow
        //            LoginManager().logIn(permissions: [.publicProfile, .email]) { result in
        //                switch result {
        //                case .success(let grantedPermissions, _, _):
        //                    // Handle successful Facebook login
        //                    print("Facebook login success. Granted permissions: \(grantedPermissions)")
        //                case .cancelled:
        //                    // Handle cancelled login
        //                    print("Facebook login cancelled")
        //                case .failure(let error):
        //                    // Handle login error
        //                    print("Facebook login error: \(error.localizedDescription)")
        //                }
        //            }
    }
    
  
    
    
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}

