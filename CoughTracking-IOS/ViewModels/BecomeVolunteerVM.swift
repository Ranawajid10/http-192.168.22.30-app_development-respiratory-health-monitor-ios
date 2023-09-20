//
//  BecomeVolunteerVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 18/09/2023.
//

import Foundation


class BecomeVolunteerVM:ObservableObject{
    
    @Published var age = ""
    @Published var gender = ""
    @Published var genderDGText = ""
    @Published var ethncity = ""
    @Published var medicalCondition = ""
    
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
        
        
        goNext.toggle()
        
        
    }
    
    
    func uploadVolunteerData(){
        
        
//        ApiClient.shared.saveVolunteerData(){
//
//
//        }
    
        
        
    }
    
    
    
}
