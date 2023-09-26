//
//  DashboardView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI
import CoreData


struct DashboardView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    
    @AppStorage(Constants.isMicStopbyUser) var isMicStoppedByUser: Bool = false
    
    @FetchRequest(entity: VolunteerCough.entity(), sortDescriptors: []) var allValunteerCoughFetchResult: FetchedResults<VolunteerCough>
    @FetchRequest(entity: TrackedHours.entity(), sortDescriptors: []) var coughTrackingHoursFetchResult: FetchedResults<TrackedHours>
    @FetchRequest(entity: HoursUpload.entity(), sortDescriptors: []) var uploadTrackingHoursFetchResult: FetchedResults<HoursUpload>
    @FetchRequest(entity: Cough.entity(), sortDescriptors: []) var coughFetchResult: FetchedResults<Cough>
    @FetchRequest(entity: UploadNotes.entity(), sortDescriptors: []) var uploadNotesFetchResult: FetchedResults<UploadNotes>
    
    @State var allCoughList:[Cough] = []
    
    
    @ObservedObject var dashboardVM = DashboardVM()
    
    @State  var showAlertOnNotificationOpen = false
    
    @State var showMicStopSheet = false
    @State var showSyncDataSheet = false
    @State var isAnalyticsMode = false
    
    
    @State var selectedDayIndex = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    @State var totalCoughCount:Int = 0
    @State var totalTrackedHours:Double = 0.0
    @State var coughsPerHour:Int = 0
    
    @State private var toast: FancyToast? = nil
    
    var body: some View {
        
        ZStack {
            
            
            
            VStack{
                
                HomeTopBar(dashboardVM: dashboardVM,showSyncDataSheet:$showSyncDataSheet)
                    .environment(\.managedObjectContext, viewContext)
                
                
                
                HStack(spacing: 0) {
                    ForEach(0..<Constants.tabList.count, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectedDayIndex = index
                            }
                        } label: {
                            Text(Constants.tabList[index])
                                .foregroundColor(selectedDayIndex == index ? Color.white : Color.gray)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 18)
                        }
                    }
                }
                .background(
                    BubbleView(selectedIndex: selectedDayIndex, tabCount: Constants.tabList.count)
                )
                .padding(.vertical, 10)
                
                Group{
                    if selectedDayIndex == 0 {
                        
                        HourlyCoughsView(dashboardVM: dashboardVM, allCoughList: $allCoughList,hourTrackedList: $dashboardVM.coughTrackHourList)
                            .environment(\.managedObjectContext, viewContext)
                            .id(1)
                        
                    } else if selectedDayIndex == 1 {
                        
                        DailyCoughsView(dashboardVM: dashboardVM,allCoughList: $allCoughList,hourTrackedList: $dashboardVM.coughTrackHourList)
                            .environment(\.managedObjectContext, viewContext)
                            .id(2)
                        
                    } else {
                        
                        WeeklyCoughsView(dashboardVM: dashboardVM, allCoughList: $allCoughList,hourTrackedList: $dashboardVM.coughTrackHourList)
                            .environment(\.managedObjectContext, viewContext)
                            .id(3)
                    }
                    
                }
                
                CustomTabView(dashboardVM: dashboardVM, showMicSheet: $showMicStopSheet,isMicStoppedByUser:$isMicStoppedByUser)
                    .environment(\.managedObjectContext, viewContext)
                
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.screenBG)
            .gesture(
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        withAnimation {
                            
                            let threshold = UIScreen.main.bounds.width / CGFloat(Constants.tabList.count + 1)
                            
                            if value.translation.width > threshold {
                                selectedDayIndex = max(0, selectedDayIndex - 1)
                            } else if -value.translation.width > threshold {
                                selectedDayIndex = min(Constants.tabList.count - 1, selectedDayIndex + 1)
                            }
                            
                        }
                    }
            )
            
            
            
            
        }.toastView(toast: $toast)
            .environment(\.managedObjectContext,viewContext)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $showSyncDataSheet, destination: {
                
                AllowSyncStatsView(text: "Save",allValunteerCoughList: $dashboardVM.valunteerCoughList ,uploadTrackingHoursList: $dashboardVM.uploadTrackingHoursList)
                    .environment(\.managedObjectContext, viewContext)
                
            })
            .sheet(isPresented: $dashboardVM.showScheduleSheet) {
                
                ScheduleMonitoringBottomSheet(dashboardVM: dashboardVM)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(35)
                
            }.sheet(isPresented: $showMicStopSheet) {
                
                MicStopBottomSheet(dashboardVM: dashboardVM, showStopMicSheet: $showMicStopSheet,isMicStoppedByUser:$isMicStoppedByUser)
                    .presentationDetents([.height(100)])
                    .presentationCornerRadius(35)
                
            }.sheet(isPresented: $showAlertOnNotificationOpen) {
                
                StartScheduleMonitoringSheet(dashboardVM: dashboardVM, showNotificationOpenAlert: $showAlertOnNotificationOpen)
                    .presentationDetents([.height(250)])
                    .presentationCornerRadius(35)
                
            }
        //            .sheet(isPresented: $showSyncDataSheet) {
        //
        //                SyncDataBottomSheet(dashboardVM: dashboardVM, showSyncDataSheet: $showSyncDataSheet)
        //                    .presentationDetents([.height(170)])
        //                    .presentationCornerRadius(35)
        //
        //            }
            .onAppear{
                
                showAlertOnNotificationOpen = MyUserDefaults.getBool(forKey: Constants.isFromNotification)
                
                dashboardVM.userData = MyUserDefaults.getUserData() ?? LoginResult()
                allCoughList.removeAll()
                dashboardVM.valunteerCoughList.removeAll()
                dashboardVM.coughTrackHourList.removeAll()
                dashboardVM.uploadTrackingHoursList.removeAll()
                dashboardVM.uploadNotesList.removeAll()
                
                allCoughList =  Array(coughFetchResult)
                
                dashboardVM.valunteerCoughList = Array(allValunteerCoughFetchResult)
                dashboardVM.coughTrackHourList = Array(coughTrackingHoursFetchResult)
                dashboardVM.uploadTrackingHoursList =  Array(uploadTrackingHoursFetchResult)
                dashboardVM.uploadNotesList =  Array(uploadNotesFetchResult)
                
                print("dashboardVM.valunteerCoughList",dashboardVM.valunteerCoughList.count)
                
                calculateTotalCoughHours()
                
                if(!isMicStoppedByUser && !dashboardVM.isRecording){
                    dashboardVM.startRecording()
                }
                
                
               
                
                
                
            }.onReceive(dashboardVM.$saveCough, perform:  { i in
                
                if(i){
                    
                    saveSimpleCough()
                    
                }
                
                
            })
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { notification in
                
                
                dashboardVM.valunteerCoughList.removeAll()
                dashboardVM.coughTrackHourList.removeAll()
                dashboardVM.uploadTrackingHoursList.removeAll()
                dashboardVM.uploadNotesList.removeAll()
                
                dashboardVM.coughTrackHourList = Array(coughTrackingHoursFetchResult)
                dashboardVM.valunteerCoughList =  Array(allValunteerCoughFetchResult)
                dashboardVM.uploadTrackingHoursList =  Array(uploadTrackingHoursFetchResult)
                dashboardVM.uploadNotesList =  Array(uploadNotesFetchResult)
                
                
                print("dashboardVM.valunteerCoughList",dashboardVM.valunteerCoughList.count)
                
                allCoughList =  Array(coughFetchResult)
                totalCoughCount = allCoughList.count
                calculateTotalCoughHours()
                
                
                
                if(MyUserDefaults.getBool(forKey:Constants.isAutoSync) && MyUserDefaults.getBool(forKey: Constants.isAutoDonate)){
                    
                    print("DashboardView","uploaded not now", dashboardVM.valunteerCoughList.count)
                    
                    if(dashboardVM.valunteerCoughList.count>=5){
                        
                        dashboardVM.calculateTrackedMinutes()
                        
                    }
                    
                }
                
                
                
            }.onReceive(dashboardVM.$isError, perform:  { i in
                
                if(i){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: dashboardVM.errorMessage)
                    dashboardVM.isError = false
                    
                }
                
                
            }).onReceive(dashboardVM.$isScheduled, perform:  { i in
                
                if(i){
                    
                    toast = FancyToast(type: .success, title: "Success!", message: "Cough scheduled successfully")
                    dashboardVM.isScheduled = false
                    
                }
                
                
            }).onReceive(dashboardVM.$isUploaded, perform:  { i in
                
                if(i){
                    
                    deleteVolunteerCough()
//                    deleteUploaddHour()
                    
                    uploadTrackingHoursFetchResult.nsSortDescriptors.removeAll()
                    allValunteerCoughFetchResult.nsSortDescriptors.removeAll()
                    dashboardVM.trackedSecondsByHour.removeAll()
                    dashboardVM.uploadTrackingHoursList.removeAll()
                    dashboardVM.valunteerCoughList.removeAll()
                    
                    print("DashboardView","uploded 5 coughs")
                    
                }
                
                
            }).onReceive(dashboardVM.$saveHours, perform:  { i in
                
                if(i){
                    
                    saveTrackedHours()
                    
                }
                
                
            })
    }
    
    func calculateTotalCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        
        let totalSeconds = coughTrackingHoursFetchResult.reduce(0) { $0 + $1.secondsTrack }
        
        let hours =  totalSeconds/3600.0
        
        
        if(hours<1){
            
            totalTrackedHours = 1
            
        }else{
            
            totalTrackedHours =  totalSeconds/3600.0
            
        }
        
        print("DashboardView",totalTrackedHours,"------",coughTrackingHoursFetchResult.count)
        
        if(totalTrackedHours > 1 && coughsPerHour > 1){
            
            coughsPerHour = totalCoughCount / Int(totalTrackedHours)
            
        }else{
            
            coughsPerHour = 0
            
        }
    }
    
    func saveSimpleCough(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let currentDate = Date()
        
        let dateString = dateFormatter.string(from: currentDate)
        
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let timeString = dateFormatter.string(from: currentDate)
        
        let id = DateUtills.getCurrentTimeInMilliseconds()
        
        
        var uniqueSegments: [(key: [[Float]], value: String)] = []
        
        for segment in dashboardVM.segments {
            // Check if the segment's key is not already in uniqueSegments
            if !uniqueSegments.contains(where: { (key, _) in key == segment.key }) {
                uniqueSegments.append(segment)
            }
        }
        
        
        
        for segmentPower in uniqueSegments {
            
            let segments = segmentPower.key
            let power = segmentPower.value
            
            // Simple Cough
            let cough = Cough(context: viewContext)
            
            cough.id = id
            cough.date = dateString
            //        cough.time = "08:00:03"
            cough.time = timeString
            cough.coughSegments = segments
            cough.coughPower = power
            
            do {
                
                try viewContext.save()
                
            } catch {
                // Handle the error
                print("Error saving data: \(error.localizedDescription)")
            }
            
            
            
            
            // saveVolunteerCough
            
            
            let volunteerCough = VolunteerCough(context: viewContext)
            
            volunteerCough.id = id
            volunteerCough.date = dateString
            volunteerCough.time = timeString
            volunteerCough.coughSegments = segments
            volunteerCough.coughPower = power
            
            do {
                try viewContext.save()
                
                
            } catch {
                // Handle the error
                print("Error saving data: \(error.localizedDescription)")
            }
            
            
            // saveNotesCough
            
            let coughNotes = CoughNotes(context: viewContext)
            
            coughNotes.id = id
            coughNotes.date = dateString
            coughNotes.time = timeString
            coughNotes.coughSegments = segments
            coughNotes.coughPower = power
            coughNotes.url = ""
            
            do {
                try viewContext.save()
                
                
                dashboardVM.segments.removeAll()
                dashboardVM.coughPower = ""
                
                
            } catch {
                // Handle the error
                print("Error saving data: \(error.localizedDescription)")
            }
            
            
        }
        
        
        
        
        
        
    }
    
    func saveVolunteerCough(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let currentDate = Date()
        
        let dateString = dateFormatter.string(from: currentDate)
        
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let timeString = dateFormatter.string(from: currentDate)
        
        
        let volunteerCough = VolunteerCough(context: viewContext)
        
        volunteerCough.id = DateUtills.getCurrentTimeInMilliseconds()
        volunteerCough.date = dateString
        volunteerCough.time = timeString
        //        volunteerCough.coughSegments = dashboardVM.segments
        volunteerCough.coughPower = dashboardVM.coughPower
        
        do {
            try viewContext.save()
            saveNotesCough()
            print("coredata","saved volunteer cough")
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
        
    }
    
    func saveNotesCough(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let currentDate = Date()
        
        let dateString = dateFormatter.string(from: currentDate)
        
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let timeString = dateFormatter.string(from: currentDate)
        
        
        let coughNotes = CoughNotes(context: viewContext)
        
        coughNotes.id = DateUtills.getCurrentTimeInMilliseconds()
        coughNotes.date = dateString
        coughNotes.time = timeString
        //        coughNotes.coughSegments = dashboardVM.segments
        coughNotes.coughPower = dashboardVM.coughPower
        coughNotes.url = ""
        
        do {
            try viewContext.save()
            print("coredata","saved volunteer cough")
            
            dashboardVM.segments = []
            dashboardVM.coughPower = ""
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
        
    }
    
    func saveTrackedHours(){
        
        
        let dateString = DateUtills.getCurrentDateInString(format: DateTimeFormats.dateTimeFormat1)
        
        
        let coughTrackingHours = TrackedHours(context: viewContext)
        
        coughTrackingHours.id = DateUtills.getCurrentTimeInMilliseconds()
        coughTrackingHours.date = dateString
        coughTrackingHours.secondsTrack = dashboardVM.totalSecondsRecordedToday
        
        do {
            
            try viewContext.save()
            saveUploadTrackedHours()
            print("savedTrackedHours")
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
    }
    
    func saveUploadTrackedHours(){
        
        
        let dateString = DateUtills.getCurrentDateInString(format: DateTimeFormats.dateTimeFormat1)
        
        
        let uploadTrackingHours = HoursUpload(context: viewContext)
        
        uploadTrackingHours.id = DateUtills.getCurrentTimeInMilliseconds()
        uploadTrackingHours.dateTime = dateString
        uploadTrackingHours.trackedSeconds = dashboardVM.totalSecondsRecordedToday
        
        do {
            
            try viewContext.save()
            print("saveUploadTrackedHours")
            
            
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
    }
    
    
    func deleteVolunteerCough() {
        
        for volunteerCough in allValunteerCoughFetchResult {
            
            viewContext.delete(volunteerCough)
        
        }
        
        for trackingHour in uploadTrackingHoursFetchResult {
            
            viewContext.delete(trackingHour)
        
        }
       
        do {
           
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



struct CustomTabView:View{
    
    @StateObject var dashboardVM : DashboardVM
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showMicSheet:Bool
    @Binding var isMicStoppedByUser:Bool
    
    @State private var isScaling = false
    
    
    var body: some View{
        
        VStack {
            
            Button(action: {
                
                withAnimation {
                    
                    showMicSheet.toggle()
                    
                }
                
            }, label: {
                
                Image("microphone_bg")
                    .overlay {
                        
                        VStack{
                            
                            Image(isMicStoppedByUser ?  "mircrophone_play" : "mircrophone_paused")
                                .resizable()
                                .frame(width: 45,height: 45)
                            
                            
                        }.frame(width: 48,height: 48)
                            .background(Color.appColorBlue)
                            .cornerRadius(24)
                        
                    }.scaleEffect(isScaling  ? 1.1 : 1.0)
                
            }).padding(.bottom,-30)
                .onAppear{
                    
                    //                   startScalingAnimation()
                    
                }
            
            ZStack {
                
                Image("bottom_bar_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width,height: 91)
                
                HStack {
                    
                    Spacer()
                    
                    NavigationLink {
                        
                        ProfileSettingsView(dashboardVM: dashboardVM)
                            .environment(\.managedObjectContext, viewContext)
                        
                    } label: {
                        
                        Image("user-avatar")
                        
                    }
                    
                    Spacer()
                    
                    
                    
                    
                    Spacer()
                    
                    NavigationLink {
                        
                        UserReportView()
                        
                    } label: {
                        Image("analytics")
                    }
                    
                    Spacer()
                    
                }
            }
            
            
            
            
        }
        
        
        
        
    }
    private func startScalingAnimation() {
        // Check if mic is not stopped and isScaling is true
        if isMicStoppedByUser && !isScaling {
            // Stop the scale animation
            withAnimation {
                isScaling = false
            }
        } else if !isMicStoppedByUser && !isScaling {
            // Start the scale animation
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isScaling = true
            }
        }
    }
    
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}


struct RotatingImage: View {
    @ObservedObject var dashboardVM:DashboardVM
    @State private var isRotating = false
    
    var body: some View {
        Image("reload")
            .foregroundColor(dashboardVM.isLoading ? .green : .appColorBlue)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .onAppear() {
                // Start rotating when the view appears
                self.startRotating()
            }
    }
    
    func startRotating() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            self.isRotating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                self.isRotating = false
            }
        }
    }
}

struct HomeTopBar: View {
    
    
    @ObservedObject  var dashboardVM:DashboardVM
    
    @Binding var showSyncDataSheet:Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack{
            
            Button {
                
                dashboardVM.showScheduleSheet = true
                
            } label: {
                
                Image("calendar")
                
            }
            
            
            NavigationLink {
                
                AllowSyncStatsView(text: "Save",allValunteerCoughList: $dashboardVM.valunteerCoughList ,uploadTrackingHoursList: $dashboardVM.uploadTrackingHoursList)
                    .environment(\.managedObjectContext, viewContext)
                //                showSyncDataSheet = true
                
                
            } label: {
                
                if(MyUserDefaults.getBool(forKey: Constants.isAutoDonate)){
                    
                    RotatingImage(dashboardVM: dashboardVM)
                    
                }else{
                    
                    Image("reload")
                        
                    
                }
                
            }.padding(.leading)
            
            
            Spacer()
            
            Text("Coughs")
                .foregroundColor(Color.appColorBlue)
                .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 20))
                .padding(.leading,-16)
            
            Spacer()
            
            NavigationLink {
                
                NotesView(dashboardVM: dashboardVM)
                    .environment(\.managedObjectContext, viewContext)
                //                    .onAppear{
                //                        dashboardVM.stopRecording()
                //                    }
                
            } label: {
                
                HStack{
                    
                    Image("list")
                        .resizable()
                        .frame(width: 16,height: 16)
                        .padding(.leading,3)
                    
                    
                    HStack{
                        
                        Image("analytics")
                            .resizable()
                            .frame(width: 16,height: 16)
                        
                    }.frame(width: 27,height: 27)
                        .background(Color.white)
                        .cornerRadius(24)
                    
                }
                .frame(width: 60,height: 33)
                .background(Color.appColorBlue)
                .cornerRadius(50)
                
                
            }
            
            
            
            
        }.padding(.horizontal)
    }
}


struct ScheduleMonitoringBottomSheet:View{
    
    @ObservedObject var dashboardVM:DashboardVM
    @State var currentHourFormatted = ""
    @State var currentHour: Int = Calendar.current.component(.hour, from: Date())
    @State var currentMinute: Int = Calendar.current.component(.minute, from: Date())
    
    
    @State private var toast: FancyToast? = nil
    
    
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh"
        return formatter
    }
    
    var amPmFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }
    
    var body: some View{
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            HStack{
                
                Spacer()
                
                Text("Schedule Cough Monitoring")
                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 20))
                
                
                Spacer()
                
                Button {
                    
                    dashboardVM.scheduleNotification()
                    
                } label: {
                    
                    Text("Save")
                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                    
                    
                }.padding(.trailing)
                
                
                
                
                
            }
            
            HStack{
                
                Picker("", selection: $dashboardVM.fromSelectedHour) {
                    
                    ForEach(1..<13){ i in
                        
                        Text(String(format: "%0\(2)d", i))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        currentHourFormatted = timeFormatter.string(from: Date())
                        dashboardVM.fromSelectedHour = Int(currentHourFormatted) ?? 1
                        dashboardVM.fromSelectedHour-=1
                    }
                
                
                Text(":")
                    .foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .medium, fontSize: 16))
                
                Picker("", selection: $dashboardVM.fromSelectedMin) {
                    
                    ForEach(1..<60){ i in
                        
                        Text(String(format: "%0\(2)d", i))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        dashboardVM.fromSelectedMin = currentMinute
                        
                    }
                
                Picker("", selection: $dashboardVM.fromSelectedAM) {
                    
                    ForEach(0..<2){ i in
                        
                        Text(String(i == 0 ? "AM" : "PM" ))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        currentHourFormatted = amPmFormatter.string(from: Date())
                        dashboardVM.fromSelectedAM = currentHourFormatted == "AM" ? 0 : 1
                        
                    }
                
                
            }.padding(.top)
            
            Text("to")
                .foregroundColor(.black)
                .modifier(LatoFontModifier(fontWeight: .medium, fontSize: 16))
            
            HStack{
                
                Picker("", selection: $dashboardVM.toSelectedHour) {
                    
                    ForEach(1..<13){ i in
                        
                        Text(String(format: "%0\(2)d", i))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        currentHourFormatted = timeFormatter.string(from: Date())
                        dashboardVM.toSelectedHour = Int(currentHourFormatted) ?? 1
                        dashboardVM.toSelectedHour-=1
                        
                    }
                
                
                Text(":")
                    .foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .medium, fontSize: 16))
                
                Picker("", selection: $dashboardVM.toSelectedMin) {
                    
                    ForEach(1..<60){ i in
                        
                        Text(String(format: "%0\(2)d", i))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        dashboardVM.toSelectedMin = currentMinute
                        
                    }
                
                Picker("", selection: $dashboardVM.toSelectedAM) {
                    
                    ForEach(0..<2){ i in
                        
                        Text(String(i == 0 ? "AM" : "PM" ))
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize:16))
                        
                        
                    }
                    
                }.pickerStyle(.wheel)
                    .frame(height: 100)
                    .onAppear{
                        
                        currentHourFormatted = amPmFormatter.string(from: Date())
                        dashboardVM.toSelectedAM = currentHourFormatted == "AM" ? 0 : 1
                        
                    }
                
                
                
            }
            
            
            
            Spacer()
            
        }.toastView(toast: $toast)
            .padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
            .onReceive(dashboardVM.$isError, perform:  { i in
                
                if(i){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: dashboardVM.errorMessage)
                    dashboardVM.isError = false
                    
                }
                
                
            })
        
        
        
    }
    
    
}


struct MicStopBottomSheet:View{
    
    @StateObject var dashboardVM : DashboardVM
    @Binding var showStopMicSheet:Bool
    @Binding var isMicStoppedByUser:Bool
    
    var body: some View{
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            Button {
                
                if(isMicStoppedByUser){
                    
                    dashboardVM.startRecording()
                    isMicStoppedByUser = false
                    
                }else{
                    
                    dashboardVM.stopRecording()
                    isMicStoppedByUser = true
                    
                }
                
                showStopMicSheet.toggle()
                
            } label: {
                
                
                Text(isMicStoppedByUser ? "Start" : "Stop")
                    .foregroundColor(isMicStoppedByUser ? Color.white : Color.red)
                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                    .frame(width: UIScreen.main.bounds.width-60,height: 42)
                    .background(isMicStoppedByUser ? Color.appColorBlue : Color.lightBlue)
                    .cornerRadius(40)
                
                
            }
            .padding(.horizontal)
            .padding(.top,20)
            
            
            Spacer()
            
        }.padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
        
        
    }
    
    
}



struct SyncDataBottomSheet:View{
    
    @StateObject var dashboardVM : DashboardVM
    @Binding var showSyncDataSheet:Bool
    
    @State var isCoughOn = false
    @State var isStatisticsOn = false
    
    @State var isError = false
    @State var errorMessage:String = ""
    
    @State private var toast: FancyToast? = nil
    
    var body: some View{
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            Toggle(isOn: $isCoughOn) {
                
                Text("Coughs")
                    .foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 18))
                
            }.padding(.horizontal)
                .backgroundStyle(Color.appColorBlue)
            
            
            
            Toggle(isOn: $isStatisticsOn) {
                
                Text("Statistics")
                    .foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 18))
                
            }.padding(.horizontal)
            
            
            Button {
                
                if(isCoughOn || isStatisticsOn){
                    
                    MyUserDefaults.saveBool(forKey: Constants.isCoughStatOn, value: isCoughOn)
                    MyUserDefaults.saveBool(forKey: Constants.isStatisticsOn, value: isStatisticsOn)
                    
                    //                    dashboardVM.decideCoughUpload()
                    
                    
                }else{
                    
                    isError = true
                    errorMessage = "Please enable cough or stats to continue"
                    
                }
                
            } label: {
                
                
                Text("Start")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width-60,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
                
            }.padding(.vertical)
            
        }.toastView(toast: $toast)
            .padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
            .onChange(of: isError){ oldValue, newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: errorMessage)
                    isError = false
                    
                }
                
            }
        
        
    }
    
    
}

struct StartScheduleMonitoringSheet:View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var showNotificationOpenAlert:Bool
    
    
    
    
    var body: some View {
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            Text("Schedule Monitoring")
                .foregroundColor(.black)
                .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 18))
                .padding(.top,8)
            
            Text("Would you like to track your coughs in the background?")
                .foregroundColor(.black)
                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                .padding(.top)
            
            Spacer()
            
            HStack(spacing: 20){
                
                Button {
                    
                    MyUserDefaults.removeDate(key: Constants.scheduledToDate)
                    MyUserDefaults.saveBool(forKey: Constants.isFromNotification, value: false)
                    showNotificationOpenAlert.toggle()
                    
                } label: {
                    
                    
                    Text("No")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black)
                    
                    
                }.frame(width: (UIScreen.main.bounds.width/2)-50,height: 42)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.appColorBlue, lineWidth: 2)
                    )
                
                Button {
                    
                    if(!dashboardVM.isRecording){
                        
                        dashboardVM.stopRecording()
                        
                    }
                    
                    MyUserDefaults.saveBool(forKey: Constants.isFromNotification, value: false)
                    showNotificationOpenAlert.toggle()
                    UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                           to: UIApplication.shared, for: nil)
                    
                } label: {
                    
                    
                    Text("Yes")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                    
                    
                }.frame(width: (UIScreen.main.bounds.width/2)-50,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
                
            }.padding(.vertical)
            
            Spacer()
            
        }
        .frame(width: UIScreen.main.bounds.width)
        .padding(.top)
        .padding(.horizontal)
        .background(Color.screenBG)
        
    }
}

