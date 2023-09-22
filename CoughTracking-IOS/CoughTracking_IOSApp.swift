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
import GoogleSignIn

@main
struct CoughTracking_IOSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
   
    init(){
        
        initializeFirebase()
        
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                
                
                if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn)){
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)){
                        
                        DashboardView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        
                    }else if(!MyUserDefaults.getBool(forKey: Constants.isAllowSync)){
                        
                        AllowSyncStatsView(text: "Continue" )
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                   
                    }else{
                        
                        BaselineView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        
                    }
                    
                    
                }else{
                    
                    SplashView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                }
            }.onAppear{
                
                MyUserDefaults.saveBool(forKey: Constants.isMicStopbyUser, value: false)
                let ur = MyUserDefaults.getUserData() ?? LoginResult()
                print("barear",ur.token ?? "")
                
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
        
        print("jjjjj")

        FirebaseApp.configure()
    
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("jjjjj")
            
            return }

        print("kkk",clientID)
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
//        let config = GIDConfiguration(clientID: Constants.googleClientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
        
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
}
