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
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showAlertOnNotificationOpen = UserDefaults.standard.bool(forKey: "showAlertOnNotificationOpen")
    
    
    init(){
        
        Functions.changeBackIconTextColor(color: .appColorBlue)
        
        
        
        initializeFirebase()
        //        deleteAllData()
        
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                
                SplashView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onAppear{
                        
                        MyUserDefaults.saveBool(forKey: Constants.isMicStopbyUser, value: false)
                        let ur = MyUserDefaults.getUserData() ?? LoginResult()
                        print("barear",ur.token ?? "")
                        
                        print("ggg",MyUserDefaults.getString(forKey: "closee"))
                        
                        MyUserDefaults.saveBool(forKey: Constants.isFromNotification, value: appDelegate.openedFromNotification)
                        MyUserDefaults.saveBool(forKey: Constants.isUploadedInThisHour, value: false)
                        
                    }
                
                
            } .accentColor(.appColorBlue)
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

class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    var openedFromNotification = false
    
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        openedFromNotification = true
        UserDefaults.standard.set(true, forKey: "showAlertOnNotificationOpen")
        UserDefaults.standard.synchronize()
        
        // Handle the notification response
        
        completionHandler()
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        //            if granted {
        //                print("Notification authorization granted")
        //            } else {
        //                print("Notification authorization denied")
        //            }
        //        }
        
        // Handle notification
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
        
        return true
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        MyUserDefaults.removeDate(key: Constants.scheduledToDate)
        
        let context = persistentContainer.viewContext
        
        let dateString = DateUtills.getCurrentDateInString(format: DateTimeFormats.dateTimeFormat1)
        let id = DateUtills.getCurrentTimeInMilliseconds()
        
        let coughTrackingHours = TrackedHours(context: context)
        
        
        coughTrackingHours.id = id
        coughTrackingHours.date = dateString
        coughTrackingHours.secondsTrack = Constants.totalSecondsRecordedToday
        
        do {
            
            try context.save()
            print("savedTrackedHours")
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
        
        let uploadTrackingHours = HoursUpload(context: context)
        
        uploadTrackingHours.id = id
        uploadTrackingHours.dateTime = dateString
        uploadTrackingHours.trackedSeconds = Constants.totalSecondsRecordedToday
        
        do {
            
            try context.save()
            print("saveUploadTrackedHours")
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("didReceiveRemoteNotification")
        
        //        if application.applicationState == UIApplication.State.inactive || application.applicationState == UIApplication.State.background {
        //            //opened from a push notification when the app was in the background
        //
        //
        //            MyUserDefaults.saveString(forKey: "from", value: "notification")
        //        }else{
        //
        //            MyUserDefaults.saveString(forKey: "from", value: "normal1")
        //
        //        }
        
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("didReceiveRemoteNotification")
        MyUserDefaults.saveString(forKey: "from", value: "notification")
        
        completionHandler([.banner, .sound])
    }
    
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        // Handle notification click here
    //
    //        // Open your app and pass data if needed
    //        // You can use the `response.actionIdentifier` or `response.notification.request.identifier` to determine which notification was clicked.
    //
    //        // For example, you can use a deep link to navigate to a specific screen in your SwiftUI app.
    //        // Replace "your-deeplink-path" with your desired deep link.
    //        if let url = URL(string: "your-deeplink-path") {
    //            // Handle deep linking
    //            // You can use this URL to navigate to a specific screen in your app
    //        }
    //
    //        // Optionally, you can also display an alert when the app is opened from a notification.
    //        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
    //            // Show an alert here
    //        }
    //
    //        completionHandler()
    //    }
    
    
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
