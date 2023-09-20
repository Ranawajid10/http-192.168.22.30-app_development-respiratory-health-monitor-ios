//
//  BecomeVolunteerVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 18/09/2023.
//

import Foundation
import UIKit


class BecomeVolunteerVM:ObservableObject{
    
    @Published var age = ""
    @Published var gender = ""
    @Published var ethncity = ""
    @Published var medicalCondition = ""
    
    @Published var isLoading = false
    
    @Published var isError = false
    @Published var errorMessage = ""
    
    @Published var goNext = false
    
    @Published var isGenderExpended = false
    @Published var selectedGenderIndex = -1

    @Published var isEthncityExpended = false
    @Published var selectedEthncityIndex = -1
    
    
    func proceed(){
    
        isError = false
        goNext = false
        
        if(age.isEmpty){
            
            isError = true
            errorMessage = "Please enter age!"
            return
            
        }
        
        if(selectedGenderIndex == -1){
            
            isError = true
            errorMessage = "Pleaee select gender!"
            return
            
        }
        
        if(selectedEthncityIndex == -1){
            
            isError = true
            errorMessage = "Please select ethncity"
            return
            
        }
        
        UIApplication.shared.endEditing()
        
        uploadVolunteerData()
        
        
    }
    
    
    func uploadVolunteerData(){
        
        isLoading = true
        
        
        ApiClient.shared.addVolunteerInfo(age: age, gender: gender, ethnicity: ethncity, medicalCondition: medicalCondition, completion: { [self] response in
           
            isLoading = false
            
            switch response {
            case .success(let success):
                
                if(success.statusCode==nil && success.email==nil && success.otp==0){
                    
                    isError = true
                    errorMessage = success.detail
                    
                }else if(success.statusCode == 201 || success.statusCode == 200){
                    
                    saveUserData()
                    
                }
                
                break
                
            case .failure(let failure):
                isError = true
                errorMessage = failure.detail[0].msg ?? ""
                break
                
            }
            
            
        })
    
        
        
    }
    
    
    func saveUserData(){
        
        var userData = MyUserDefaults.getUserData() ?? LoginResult()
        
        userData.age = Int(age)
        userData.gender = gender
        userData.ethnicity = ethncity
        userData.medicalConditions = medicalCondition
        
        MyUserDefaults.saveUserData(value: userData)
        
        print(MyUserDefaults.getUserData() ?? LoginResult())
        
        goNext.toggle()
        
    }
    
    
}
