//
//  SendOtpVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation
import Combine

class SendOtpVM:ObservableObject{
    
    @Published var email: String = ""
    @Published var fcmToken: String = ""
    @Published var loginWith: String = ""
    @Published var mailOTP: Int = 0
    @Published var enteredOTP: Int = 0
    
    
    @Published var goNext = false
    @Published var isVarified = false
    @Published var isEmailSent = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    @Published var counter = 0
    @Published var doit = false
    @Published var isTimerRunning = false
    @Published var remainingTime = 59 // Initial value is 2 seconds
    
    private var timer: Timer?
    private var cancellable: AnyCancellable?
    
    
    
    func sendOtpToMail(){
        
        isLoading = true
        
        ApiClient.shared.sendOTP(email: email, fcm: fcmToken){ [self] response in
            
            isLoading = false
            
            switch response {
            case .success(let success):
                
                if(success.statusCode==nil && (success.otp != 0) && !(success.detail.isEmpty)){
                    
                    isEmailSent = false
                    isError = true
                    errorMessage = success.detail
                    
                }else if(success.statusCode == 201 || success.statusCode == 200){
                    
                    errorMessage = success.detail
                    mailOTP = success.otp
                    isEmailSent = true
                    
                    print("dadadad",mailOTP)
                    
                    startTimer()
                    
                    
                }
                
                break
                
            case .failure(let failure):
                isError = true
                errorMessage = failure.detail[0].msg ?? ""
                break
                
            }
        
           
        }
        
        
    }
    
    func startTimer() {
        

        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.counter < 59 {
                    self.counter += 1
                    self.remainingTime = 59 - self.counter // Update remaining time
                } else {
                    self.timer?.invalidate()
                    self.isTimerRunning = false
                }
            }
        
        isTimerRunning = true
    }
    
    
    
    
    
    
}
