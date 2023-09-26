//
//  ProfileSettingsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI
import CoreData

struct ProfileSettingsView: View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Environment(\.managedObjectContext) private var viewContext
    @State var isSyncData = false
    @State var showAlert = false
    @State var showConfirmDeleteAccount = false
    @State var showLogout = false
    @State var showNotification = false
    @State var goGetStarted = false
    
    @StateObject var profileSettingsVM = ProfileSettingsVM()
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                
                VStack {
                    
                    NavigationLink {
                        
                        MyProfileView()
                        
                    } label: {
                        
                        HStack{
                            
                            Image("user")
                            
                            Text("My Profile")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            
                        }
                    }
                    
                    
//                    Button {
//                        
//                        showAlert.toggle()
//                        showNotification.toggle()
//                        
//                    } label: {
//                        
//                        HStack{
//                            
//                            Image("bell")
//                            
//                            Text("Notifications")
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
//                                .foregroundColor(.black)
//                            
//                            Spacer()
//                            
//                            
//                        }
//                    }.padding(.top)
                    
                    
                    NavigationLink {
                        
                        ClearHistoryView()
                            .environment(\.managedObjectContext,viewContext)
                        
                    } label: {
                        
                        HStack{
                            
                            Image("history")
                            
                            Text("Clear history")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            
                        }
                    }.padding(.top)
                    
                    
                    NavigationLink {
                        
                        AllowSyncStatsView(text: "Save",allValunteerCoughList: $dashboardVM.valunteerCoughList ,uploadTrackingHoursList: $dashboardVM.uploadTrackingHoursList)
                            .environment(\.managedObjectContext,viewContext)
                        
                    } label: {
                        
                        HStack{
                            
                            Image(systemName:"cloud")
                                .resizable()
                                .frame(width: 24,height: 20)
                                .foregroundColor(Color.black)
                            
                            
                            Text("Synchronise data")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(.black)
                            
                            
                            Spacer()
                            
                        }
                        
                    }.padding(.top)
                    
                    
                    
                    
                    
                    Button {
                        
                        showLogout = false
                        showAlert.toggle()
                        showConfirmDeleteAccount = true
                        
                        
                    } label: {
                        
                        HStack{
                            
                            Image("delete")
                            
                            Text("Delete account")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            
                        }
                    }.padding(.top)
                    
                    Button {
                        
                        showConfirmDeleteAccount = false
                        showAlert.toggle()
                        showLogout = true
                        
                        
                    } label: {
                        
                        HStack{
                            
                            Image("exit")
                                .resizable()
                                .frame(width: 24,height: 24)
                            
                            Text("Sign out")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            
                        }
                    }.padding(.top)
                    
                }.padding()
            }
            
            if(profileSettingsVM.isLoading){
                
                LoadingView()
                
            }
            
        }.navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .customAlert(isPresented: $showNotification) {
                
                CustomAlertView(
                    showVariable: $showNotification, showTwoButton: false, message: "Feature Under Development",
                    action: {
                        print("Okay Clicked")
                    }
                )
                
            }
            .customAlert(isPresented: $showConfirmDeleteAccount) {
                
                CustomAlertView(
                    showVariable: $showConfirmDeleteAccount, showTwoButton: true, message: "Do you want to delete this account?",
                    action: {
                        profileSettingsVM.deleteAccount()
                    }
                )
                
            }
            .customAlert(isPresented: $showLogout) {
                
                CustomAlertView(
                    showVariable: $showLogout, showTwoButton: true, message: "Are you sure you want to signout?",
                    action: {
                        
                        doSignOut()
                        
                    }
                )
                
            }.navigationDestination(isPresented: $goGetStarted) {
                
                SplashView()
                    .environment(\.managedObjectContext,viewContext)
                
            }.onReceive(profileSettingsVM.$isDeleted, perform:  { i in
                
                if(i){
                    
                    doSignOut()
                    
                }
                
            })
        
    }
    
    
    func doSignOut(){
        
        dashboardVM.stopRecording()
        dashboardVM.stopRecording()
        
        if(dashboardVM.isRecording){
            
            dashboardVM.stopRecording()
            
        }
        
        profileSettingsVM.isLoading = true
        goGetStarted = false
        
        MyUserDefaults.saveBool(forKey: Constants.isLoggedIn, value: false)
        
        MyUserDefaults.saveBool(forKey: Constants.isAllowSync, value: false)
        MyUserDefaults.saveBool(forKey: Constants.isAutoSync, value: false)
        MyUserDefaults.saveBool(forKey: Constants.isAutoDonate, value: false)
        MyUserDefaults.saveBool(forKey: Constants.isDonateForResearch, value: false)
        MyUserDefaults.saveBool(forKey: Constants.isShareWithDoctor, value: false)
        MyUserDefaults.saveString(forKey: Constants.shareWithDoctor, value:  Constants.syncOptionsList[1])
        MyUserDefaults.saveString(forKey: Constants.donateForResearch, value:  Constants.syncOptionsList[1])
        MyUserDefaults.removeUserData()
        
        
        
        
        deleteCoughData()
//        deleteBaseLinehData()
        deleteVolunteer()
        deleteTrackedHour()
        deleteUploaddHour()
        deleteCoughNotes()
        
        
        profileSettingsVM.isLoading = false
        goGetStarted = true
        
    }
    
    func deleteCoughData() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Cough")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    func deleteBaseLinehData() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoughBaseline")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    func deleteVolunteer() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VolunteerCough")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    
    func deleteTrackedHour() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackedHours")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    func deleteUploaddHour() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "HoursUpload")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    func deleteCoughNotes() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoughNotes")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
}

struct CustomAlertView: View {
    @Binding var showVariable:Bool
    var showTwoButton:Bool
    var message: String
    var action: () -> Void
    
    var body: some View {
        VStack {
            
            
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            HStack(spacing: 20){
                
                if(showTwoButton){
                    Button {
                        
                        showVariable.toggle()
                        
                    } label: {
                        
                        
                        Text("No")
                            .font(.system(size: 16))
                            .foregroundColor(Color.black)
                        
                        
                    }.frame(width: 70,height: 42)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    
                }
                
                
                
                Button {
                    
                    showVariable.toggle()
                    action()
                    
                } label: {
                    
                    
                    Text(showTwoButton ? "Yes" : "Okay")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                    
                    
                }.frame(width: 70,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
                
            }.padding(.vertical,32)
            
        }
        .frame(width: UIScreen.main.bounds.width-50)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


extension View {
    func customAlert<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                
                content()
            }
        }
    }
}

//struct ProfileSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileSettingsView()
//    }
//}


