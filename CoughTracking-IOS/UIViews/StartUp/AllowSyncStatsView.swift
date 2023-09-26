//
//  AllowSyncStatsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/09/2023.
//

import SwiftUI
import CoreData


struct AllowSyncStatsView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(entity: VolunteerCough.entity(), sortDescriptors: []) var allValunteerCoughFetchResult: FetchedResults<VolunteerCough>
//    @FetchRequest(entity: HoursUpload.entity(), sortDescriptors: []) var uploadTrackingHoursFetchResult: FetchedResults<HoursUpload>
//    
    @State var text:String
    @Binding var allValunteerCoughList:[VolunteerCough]
    @Binding var uploadTrackingHoursList:[HoursUpload]

    @State var showShareWithDoctorAlert = false
    @State var showDonateAlert = false

    @State var isAutoDonate = false
    @State var isAutoSyncOn = false
    @State var isShareWithDoctor = false
    @State var isDonateForResearch = false
    @State var goNext = false
    @State var saved = false

    @State var shareWithDoctor = Constants.syncOptionsList[1]
    @State var donateForResearch = Constants.syncOptionsList[1]

    @State private var toast: FancyToast? = nil
    
    @StateObject var allowSyncStatsVM = AllowSyncStatsVM()
    
    
//    @FetchRequest(entity: CoughBaseline.entity(), sortDescriptors: []) var coughBaselineFetchResult: FetchedResults<CoughBaseline>
//
    
    var body: some View {
        
        ZStack{
            
            VStack{
                
                Toggle(isOn: $isAutoSyncOn) {

                    Text("Auto Syncronization")
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        .foregroundColor(Color.black)

                }.padding(.trailing)
                    .tint(Color.appColorBlue)
                
                if(isAutoSyncOn){

                    HStack {

                        Text("Data Access Control")
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 18))
                            .foregroundColor(Color.black90)

                        Spacer()

                    }.padding(.top,32)


                    Toggle(isOn: $isShareWithDoctor) {

                        HStack{

                            Text("Share with you Doctor")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(Color.black)

                            Button {

                                withAnimation {
                                    showShareWithDoctorAlert.toggle()
                                }

                            } label: {

                                Image(systemName: "info.circle")

                            }


                        }
                    }.padding(.trailing)
                        .tint(Color.appColorBlue)
                        .padding(.top,8)

                    if(isShareWithDoctor){
                        RadioButtonGroup(items: Constants.syncOptionsList, selectedId: shareWithDoctor) { selected in

                            shareWithDoctor = selected

                        }
                    }


                    Toggle(isOn: $isDonateForResearch) {

                        HStack {

                            Text("Donate for research and product improvement")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(Color.black)


                            Button {

                                withAnimation {
                                    showDonateAlert.toggle()
                                }

                            } label: {

                                Image(systemName: "info.circle")

                            }.padding(.bottom)

                        }

                    }.padding(.trailing)
                        .tint(Color.appColorBlue)
                        .padding(.top,24)

                    if(isDonateForResearch){
                        RadioButtonGroup(items: Constants.syncOptionsList, selectedId: donateForResearch) { selected in

                            donateForResearch = selected

                        }
                    }


                    Spacer()

                    HStack{

                        if(isDonateForResearch){

                            Button {


                                withAnimation {

                                    isAutoDonate.toggle()

                                }

                            } label: {

                                HStack{

                                    Image(isAutoDonate ? "checked" : "unchecked" )
                                        .resizable()
                                        .frame(width: 24, height: 24)


                                    Text("Auto donate, Don’t ask again")
                                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                        .foregroundColor(Color.black)

                                }

                            }

                        }
                        Spacer()

                    }

                }
                else{


                    Spacer()

                }

                Button {



                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)  ){

                        MyUserDefaults.saveBool(forKey: Constants.isAutoSync, value: isAutoSyncOn)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoDonate, value: isAutoDonate)
                        MyUserDefaults.saveBool(forKey: Constants.isShareWithDoctor, value: isShareWithDoctor)
                        MyUserDefaults.saveString(forKey: Constants.shareWithDoctor, value: shareWithDoctor)
                        MyUserDefaults.saveBool(forKey: Constants.isDonateForResearch, value: isDonateForResearch)
                        MyUserDefaults.saveString(forKey: Constants.donateForResearch, value: donateForResearch)

                        if(allValunteerCoughList.count>0&&uploadTrackingHoursList.count>0){
                           
                            allowSyncStatsVM.calculateTrackedMinutes()
                            
                        }else{
                            
                            saved = true
                            
                        }
                        
                        
                    }else{

                        MyUserDefaults.saveBool(forKey:Constants.isAllowSync, value: true)
                        MyUserDefaults.saveBool(forKey:Constants.isBaseLineSet, value: false)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoSync, value: isAutoSyncOn)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoDonate, value: isAutoDonate)
                        MyUserDefaults.saveBool(forKey: Constants.isShareWithDoctor, value: isShareWithDoctor)
                        MyUserDefaults.saveString(forKey: Constants.shareWithDoctor, value: shareWithDoctor)
                        MyUserDefaults.saveBool(forKey: Constants.isDonateForResearch, value: isDonateForResearch)
                        MyUserDefaults.saveString(forKey: Constants.donateForResearch, value: donateForResearch)

                        goNext = true

                    }

                } label: {


                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)

                }
                .padding(.top,24)
                
                
            }
            .padding()
            
            if(allowSyncStatsVM.isLoading){
                
                LoadingView()
                
            }
            
        }
        .environment(\.managedObjectContext,viewContext)
        .toastView(toast: $toast)
        .navigationTitle("Data Sync")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.screenBG)
        .navigationDestination(isPresented: $goNext) {

            if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)){

                DashboardView()
                    .environment(\.managedObjectContext,viewContext)
                    .onAppear{

                        MyUserDefaults.saveBool(forKey: Constants.isBaseLineSet, value: true)

                    }

            }else{

                BaselineView()
                    .environment(\.managedObjectContext,viewContext)

            }

        }.onChange(of: isAutoSyncOn) { oldValue, newValue in
            if(!newValue){

                withAnimation {
                    isShareWithDoctor = false
                    isDonateForResearch = false
                }

            }
        }
        .onAppear{

            allowSyncStatsVM.userData = MyUserDefaults.getUserData() ?? LoginResult()
            allowSyncStatsVM.coughTrackHourList = uploadTrackingHoursList
            allowSyncStatsVM.valunteerCoughList = allValunteerCoughList

            if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn) && MyUserDefaults.getBool(forKey: Constants.isBaseLineSet) ){


                isAutoDonate = MyUserDefaults.getBool(forKey: Constants.isAutoDonate)
                isAutoSyncOn = MyUserDefaults.getBool(forKey: Constants.isAutoSync)
                isShareWithDoctor = MyUserDefaults.getBool(forKey: Constants.isShareWithDoctor)
                isDonateForResearch = MyUserDefaults.getBool(forKey: Constants.isDonateForResearch)


                if let index = Constants.syncOptionsList.firstIndex(of: MyUserDefaults.getString(forKey: Constants.shareWithDoctor)) {


                    shareWithDoctor = Constants.syncOptionsList[index]

                }


                if let index1 = Constants.syncOptionsList.firstIndex(of: MyUserDefaults.getString(forKey: Constants.donateForResearch)) {


                    donateForResearch = Constants.syncOptionsList[index1]

                }



            }


        }
        .onReceive(allowSyncStatsVM.$isUploaded, perform:  { i in
            
            if(i){
                
                deleteVolunteerCough()
                deleteUploaddHour()
                
              allValunteerCoughList.removeAll()
                uploadTrackingHoursList.removeAll()

                allowSyncStatsVM.coughTrackHourList.removeAll()
                allowSyncStatsVM.valunteerCoughList.removeAll()

                
                saved = true
                
                
            }
            
            
        }).onReceive(allowSyncStatsVM.$isError, perform:  { i in
            
            if(i){
                
                toast = FancyToast(type: .error, title: "Error!", message:allowSyncStatsVM.errorMessage)
                allowSyncStatsVM.isError = false
                
                
            }
            
            
        })
        .onChange(of: saved, perform: { newValue in
            if(newValue){

                toast = FancyToast(type: .success, title: "Success", message: "Data sync saved successfully")
                saved = false

            }

        }).customAlert(isPresented: $showShareWithDoctorAlert) {

            CustomAlertView(
                showVariable: $showShareWithDoctorAlert, showTwoButton: false, message: "Your cough data will be share with the doctor.",
                action: {
                    print("Okay Clicked")
                }
            )

        }.customAlert(isPresented: $showDonateAlert) {

            CustomAlertView(
                showVariable: $showDonateAlert, showTwoButton: false, message: "Your cough and statistics will be donate for research.",
                action: {
                    print("Okay Clicked")
                }
            )

        }
    }
    
    func deleteVolunteerCough() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VolunteerCough")
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
}
//
//struct AllowSyncStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllowSyncStatsView(text: "Continue",allValunteerCoughList: [],)
//    }
//}



