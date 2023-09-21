//
//  CoughTracking_IOSApp.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 20/09/2023.
//

import SwiftUI
import PythonKit
import Firebase
import CoreData
import AVFoundation

@main
struct CoughTracking_IOSApp: App {
    
    let persistenceController = PersistenceController.shared
    @StateObject var networkManager = NetworkManager()
   
    init(){
        
        initializeFirebase()
        
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                
                
                if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn)){
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)){
                        
                        DashboardView()
                            .environmentObject(networkManager)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        
                    }else{
                        
                        BaselineView()
                            .environmentObject(networkManager)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                    
                    
                }else{
                    
                    SplashView()
                        .environmentObject(networkManager)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                }
            }.onAppear{
                
                var ur = MyUserDefaults.getUserData() ?? LoginResult()
                print("barear",ur.token)
                
            }
        }
    }
    
    func deleteAllData() {
        //            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoughBaseline")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Cough")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistenceController.container.viewContext.execute(deleteRequest)
            try persistenceController.container.viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    
    func initializeFirebase(){
        
        FirebaseApp.configure()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
        
    }
}
