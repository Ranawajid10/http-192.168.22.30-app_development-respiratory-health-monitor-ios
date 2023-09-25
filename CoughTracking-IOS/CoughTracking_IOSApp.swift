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
//        deleteAllData()
        
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                
                SplashView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                
            }.onAppear{
                
                MyUserDefaults.saveBool(forKey: Constants.isMicStopbyUser, value: false)
                let ur = MyUserDefaults.getUserData() ?? LoginResult()
                print("barear",ur.token ?? "")
                
                print(MyUserDefaults.getString(forKey: "savedTrackedHours"),"savedTrackedHours")
                
            }
        }
    }
    
    func deleteAllData() {
        //            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoughBaseline")
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Cough")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoughTrackingHours")
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
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {return }
        
       
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
    
    lazy var persistentContainer: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "CoughMoniterCoreModel")
           container.loadPersistentStores { _, error in
               if let error = error as NSError? {
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           }
           return container
       }()
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        let context = persistentContainer.viewContext
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let currentDate = Date()
        
        let dateString = dateFormatter.string(from: currentDate)
        
        
        let coughTrackingHours = CoughTrackingHours(context: context)
        
        
        coughTrackingHours.date = dateString
        coughTrackingHours.secondsTrack = Constants.totalSecondsRecordedToday
        
        do {
            
            try context.save()
            print("savedTrackedHours")
            MyUserDefaults.saveString(forKey: "savedTrackedHours", value: "savedTrackedHours on " + DateUtills.getCurrentTimeInMilliseconds())
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
        
//        NotificationCenter.default.post(name: .appTerminateNotification, object: DateUtills.getCurrentTimeInMilliseconds())
//        print("terminate","phase")
//        MyUserDefaults.saveString(forKey: "phase", value: "background on " + DateUtills.getCurrentTimeInMilliseconds())
//
        
    }
//
//    func saveTrackedHours(){
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//
//        let currentDate = Date()
//
//        let dateString = dateFormatter.string(from: currentDate)
//
//
//        let coughTrackingHours = CoughTrackingHours(context: viewContext)
//
//
//        coughTrackingHours.date = dateString
//        coughTrackingHours.secondsTrack = dashboardVM.totalSecondsRecordedToday
//
//        do {
//
//            try viewContext.save()
//            print("savedTrackedHours")
//            MyUserDefaults.saveString(forKey: "savedTrackedHours", value: "savedTrackedHours on " + DateUtills.getCurrentTimeInMilliseconds())
//
//
//        } catch {
//            // Handle the error
//            print("Error saving data: \(error.localizedDescription)")
//        }
//
//    }
}
