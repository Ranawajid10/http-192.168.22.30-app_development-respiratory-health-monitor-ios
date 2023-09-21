//
//  VolunteerParticipationVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 20/09/2023.
//

import Foundation
import CoreData

class VolunteerParticipationVM:ObservableObject{
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    
    @Published var allCoughList:[VolunteerCough] = []
    @Published var selectedCoughsList:[VolunteerCough] = []
    
    func donateSamples(){
        
        isLoading = true
        
        
        print("timespent",DateUtills.getCurrentTimeInMilliseconds())
        
        ApiClient.shared.uploadSamples(allCoughList: allCoughList) { [self] response in
        
            isLoading = true
            
            print("Res",response)
            print("timespent",DateUtills.getCurrentTimeInMilliseconds())
            
        }
        
        
    }
    
}
