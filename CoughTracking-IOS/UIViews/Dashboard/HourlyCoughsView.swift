//
//  HourlyCoughsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI
import AAInfographics
import CoreData
import Combine

struct HourlyCoughsView: View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var allCoughList:[Cough]
    @Binding var hourTrackedList:[CoughTrackingHours]
    
    
    @State var totalCoughCount:Int = 0
    @State var totalTrackedHours:Double = 0.0
    @State var coughsPerHour:Int = 0
    
    
    @State private var selectedDate = Date()
    @State private var currentHour = Calendar.current.component(.hour, from: Date())
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @FetchRequest(entity: Cough.entity(), sortDescriptors: []) var coughFetchResult: FetchedResults<Cough>
    
    
    @State var moderateTimeData: [String: Int] = [:]
    @State var severeTimeData: [String: Int] = [:]
    
    @State var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @State var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @State var changeGraph:Int = 0
    
    @State var userData = LoginResult()
    
    let array = ["05:00", "10:00", "15:00", "20:00", "25:00", "30:00",
                 "35:00", "40:00", "45:00", "50:00", "55:00", "60:00"]
    
    
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack {
                    
                    
                    DaySelectionView(selectedDate: $selectedDate)
                    
                    HourlyReportView(totalCoughCount: $totalCoughCount, totalTrackedHours: $totalTrackedHours, coughsPerHour: $coughsPerHour)
                        .onAppear{
                            
                            print("jj",totalTrackedHours)
                        }
                    
                    
                    HourSelectionView(currentHour: $currentHour, selectedDate: $selectedDate)
                    
                    HourlyCoughGraph()
                    
                    
                    HourlyGraphView(moderateCoughData: $sortedModerateTimeDataDictionary, severeCoughData: $sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                        .id(changeGraph)
                    
                    
                    HStack{
                        
                        Spacer()
                        
                        Text("Time (24 hrs)")
                            .foregroundColor(Color.appColorBlue)
                            .font(.system(size: 14))
                            .padding(.trailing)
                        
                    }
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isAutoDonate)){
                        
                        HStack{
                            
                            Image("help")
                                .resizable()
                                .frame(width: 24,height: 24)
                            
                            Text("Volunteer Participation")
                                .foregroundColor(Color.black90)
                                .font(.system(size: 18))
                                .bold()
                            
                            Spacer()
                            
                        }.padding(.horizontal,24)
                            .padding(.top,10)
                        
                        Text("Your volunteer participation by donating only your cough samples will help efforts to improve healthcare services globally. Please take a step ahead and play your part.")
                            .foregroundColor(Color.darkBlue)
                            .font(.system(size: 14))
                            .padding(.horizontal,8)
                            .multilineTextAlignment(.leading)
                        
                        
                        
                        NavigationLink {
                            
                            if(userData.age==nil && userData.gender==nil && userData.ethnicity==nil){
                                
                                BecomeVolunteerView(dashboardVM: dashboardVM, allCoughList: $allCoughList)
                                    .environment(\.managedObjectContext, viewContext)
                                
                            }else{
                                
                                VolunteerParticipationView(dashboardVM: dashboardVM)
                                    .environment(\.managedObjectContext, viewContext)
//                                    .onAppear{
//                                        
//                                        dashboardVM.stopRecording()
//                                        
//                                    }.onDisappear{
//                                        
//                                        if(!MyUserDefaults.getBool(forKey: Constants.isMicStopbyUser)){
//                                            dashboardVM.startRecording()
//                                        }
//                                    }
                                
                            }
                            
                        } label: {
                            
                            
                            Text("I want to volunteer")
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                                .frame(width: UIScreen.main.bounds.width-60,height: 42)
                                .background(Color.appColorBlue)
                                .cornerRadius(40)
                            
                            
                        }.padding(.top)
                        
                    }
                    
                    Spacer()
                    
                }
            }
        }.onChange(of: selectedDate, perform: { newValue in
            
            getGraphData()
            
        })
        .onChange(of: currentHour, perform: { newValue in
            
            getGraphData()
            
        }).onAppear{
            
            userData = MyUserDefaults.getUserData() ?? LoginResult()
            getGraphData()
            
        }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            
            getGraphData()
            
        }
        
    }
    
    func calculateCurrentCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        var totalSeconds = 0.0
        
        for second in hourTrackedList {
            
            if(dateString == second.date){
                
                totalSeconds+=second.secondsTrack
                
            }
            
        }
        
        let hours =  totalSeconds/3600.0
      
        
        if(hours<1){
            
            totalTrackedHours = 1.0
            
        }else{
            
            totalTrackedHours =  totalSeconds/3600.0
            
        }
        
//        totalTrackedHours = totalSeconds/3600.0
//        print("coughsPerHour","0","--",totalCoughCount,"--",totalTrackedHours)
        
        
//        if(Int(totalTrackedHours) > 1 && totalCoughCount > 1){

            coughsPerHour = totalCoughCount / Int(totalTrackedHours)
            print("coughsPerHour","1",coughsPerHour,"--",totalCoughCount)
//
//        }else{
//
//            coughsPerHour = 0
//            print("coughsPerHour","2",coughsPerHour,"--",totalCoughCount)
//
//        }
    }
    
    
    func getGraphData(){
        
        let (currentDateCoughs,times) = getCurrentCoughs(text: String(currentHour))
       
        
        totalCoughCount = currentDateCoughs.count
        
        moderateTimeData.removeAll()
        severeTimeData.removeAll()
        
        
        for hour in array {
            moderateTimeData[hour, default: 0] = 0
            severeTimeData[hour, default: 0] = 0
        }
        
        
        
        for cough in currentDateCoughs {
            guard let coughTime = cough.time else {
                continue
            }
            
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
            let minutes = coughTime.dropFirst(3).dropLast(3)
            
            // Initialize variables to track whether the cough time falls within an interval
            var isWithinInterval = false
            var mainIndex = ""
            
            for (index, interval) in array.enumerated() {
                if index < array.count - 1 {
                    // Extract start and end minutes of the interval
                    let startMinutes = interval.dropLast(3)
                    let endMinutes = array[index + 1].dropLast(3)
                    //
                    //
                    //                    print("startMinutes",startMinutes,"------ endMinutes",endMinutes)
                    
                    if minutes >= startMinutes && minutes < endMinutes {
                        isWithinInterval = true
                        mainIndex = array[index + 1]
                        break
                    }
                }
            }
            
            if isWithinInterval {
                let coughType = cough.coughPower
                
                if coughType == "moderate" {
                    moderateTimeData[mainIndex, default: 0] += 1
                } else if coughType == "severe" {
                    severeTimeData[mainIndex, default: 0] += 1
                }
            }
        }
        
        
        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()
        
        let moderateList = moderateTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedModerateTimeDataDictionary = moderateList
        
        
        let severeList = severeTimeData.sorted { v1, v2 in
            
            let a = v1.key.dropLast(3)
            let b = v2.key.dropLast(3)
            
            return a < b
        }
        
        sortedSevereTimeDataDictionary = severeList
        
        //        withAnimation {
        
        calculateCurrentCoughHours()
        
        changeGraph+=1
        
        //        }
        
        
        print("Graph Data",currentDateCoughs.count,"---",times.count,"---Moderate---",sortedModerateTimeDataDictionary,"---Severe---",sortedSevereTimeDataDictionary)
        
        
    }
    
    func getCurrentCoughs(text:String) -> ([Cough],[String]){
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            if cough.date == dateString {
                
                
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                
                if(coughTime == text){
                    
                    coughTimes.append(coughTime)
                    currentDateCoughsList.append(cough)
                }
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
    
    
    
}

//struct HourlyCoughsView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        HourlyCoughsView(totalCoughCount: <#Binding<Int>#>, totalTrackedHours: <#Binding<Int>#>, coughsPerHour: <#Binding<Int>#>)
//    }
//}

struct HourSelectionView: View {
    
    @Binding var currentHour:Int
    @Binding var selectedDate: Date
    
    
    var body: some View {
       
        HStack {
            
            
            Button {
                
                withAnimation {
                    
                    previousHour()
                    
                }
                
            } label: {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
            }
            
            
            
            Text(String(currentHour)+":00")
                .padding(.horizontal)
            
            
            
            
            
            Button {
                
                withAnimation {
                    
                    nextHour()
                    
                }
                
            } label: {
                Image(systemName: "chevron.forward")
                    .foregroundColor(Color.black)
            }
            
            
        }
        .padding(.horizontal, 32)
        .padding(.top,16)
    }
    
    func nextHour() {
        
        currentHour = (currentHour + 1) % 24
        
        if(currentHour==0){
            
            nextDay()
            
        }
        
    }
    
    func previousHour() {
        
        currentHour = (currentHour - 1 + 24) % 24
        
        if(currentHour==0){
            
            previousDay()
            
        }
    }
    
    
    func nextDay(){
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
        if tomorrow <= Date() {
            selectedDate = tomorrow
        }
        
    }
    
    func previousDay(){
        
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
        
    }
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
}

struct DaySelectionView: View {
    
    @Binding var selectedDate:Date
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    
    var body: some View {
        HStack {
            
            
            Button {
                
                withAnimation {
                    
                    previous()
                    
                }
                
            } label: {
              
                Image(systemName: "chevron.backward")
                    .foregroundColor(Color.black)
           
            }.frame(width: 20,height: 20)
            
            Spacer()
            
            Text(isToday(selectedDate) ? "Today" : dateFormatter.string(from: selectedDate))
            
            
            Spacer()
            
            Button {
                
                withAnimation {
                    
                    next()
                    
                }
                
            } label: {
                
                Image(systemName: "chevron.forward")
                    .foregroundColor(Color.black)
                
            }.frame(width: 20,height: 20)
            .disabled(Calendar.current.isDateInTomorrow(selectedDate))
            
        }
        .padding(.horizontal, 32)
    }
    
    func next(){
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
        if tomorrow <= Date() {
            selectedDate = tomorrow
        }
        
    }
    
    func previous(){
        
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
        
    }
    
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
}



struct HourlyReportView: View {
    
    @Binding var totalCoughCount:Int
    @Binding var totalTrackedHours:Double
    @Binding var coughsPerHour:Int
    
    var body: some View {
        HStack{
            
            VStack{
                
                Text("\(totalCoughCount)")
                    .foregroundColor(Color.skyBlue)
                    .bold()
                    .font(.system(size: 16))
                
                Text("Coughs")
                    .foregroundColor(Color.black90)
                    .font(.system(size: 12))
                
            }
            
            Spacer()
            
            VStack{
                
                Text("\(Int(totalTrackedHours))")
                    .foregroundColor(Color.skyBlue)
                    .bold()
                    .font(.system(size: 16))
                
                Text("Hours tracked")
                    .foregroundColor(Color.black90)
                    .font(.system(size: 12))
                
            }
            
            Spacer()
            
            VStack{
                
                Text("\(coughsPerHour)")
                    .foregroundColor(Color.skyBlue)
                    .bold()
                    .font(.system(size: 16))
                
                Text("Coughs/Hours")
                    .foregroundColor(Color.black90)
                    .font(.system(size: 12))
                
            }
            
            
        }
        .padding()
        .frame(height: 57)
        .background(Color.lightBlue)
        .cornerRadius(13)
        .padding(.horizontal)
        .padding(.top,14)
    }
}

struct HourlyCoughGraph:View{
    
    var body: some View{
        
        VStack{
            
            HStack{
                
                Text("Cough intenstity")
                    .foregroundColor(Color.appColorBlue)
                    .font(.system(size: 14))
                
                
                Spacer()
                
                Color.blue
                    .frame(width: 15,height: 3)
                    .cornerRadius(3)
                
                Text("Moderate")
                    .font(.system(size: 12))
                    .foregroundColor(Color.greyColor)
                
                Color.red
                    .frame(width: 15,height: 3)
                    .cornerRadius(3)
                
                Text("Severe")
                    .font(.system(size: 12))
                    .foregroundColor(Color.greyColor)
                
                
            }
            
            
        }.padding(.horizontal,24)
            .padding(.top,40)
        
    }
    
}

struct HourlyGraphView: UIViewRepresentable {
    func updateUIView(_ uiView: AAInfographics.AAChartView, context: Context) {
        
    }
    
    
    @Binding var moderateCoughData: [(key: String, value: Int)]
    @Binding var severeCoughData: [(key: String, value: Int)]
    
    //    @State time
    
    //    func updateUIView(_ uiView: AAChartView, context: Context) {
    //            let aaChartModel = AAChartModel()
    //                .chartType(.column)
    //                .stacking(.percent)
    //                .legendEnabled(false)
    //                .borderRadius(10)
    //                .dataLabelsEnabled(true)
    //                .animationDuration(0)
    //                .categories(Array(coughData.keys))
    //                .colorsTheme(["#38B6FF", "#D92429"])
    //                .series([
    //                    AASeriesElement()
    //                        .name("Moderate")
    //                        .data(coughData["moderate"] ?? []),
    //                    AASeriesElement()
    //                        .name("Severe")
    //                        .data(coughData["severe"] ?? []),
    //                ])
    //        DispatchQueue.main.async {
    //            uiView.aa_drawChartWithChartModel(aaChartModel)
    //        }
    //        }
    //
    //        func makeUIView(context: Context) -> AAChartView {
    //            let aaChartView = AAChartView()
    //            return aaChartView
    //        }
    //
    func makeUIView(context: Context) -> AAChartView {
        let aaChartView = AAChartView()
        
        let aaChartModel = AAChartModel()
            .animationType(.bounce)
            .chartType(.column)
            .stacking(.normal)
            .legendEnabled(false)
            .borderRadius(10)
            .dataLabelsEnabled(true)
            .categories(["05:00", "10:00", "15:00", "20:00", "25:00", "30:00",
                         "35:00", "40:00", "45:00", "50:00", "55:00", "60:00"])
            .colorsTheme(["#38B6FF","#D92429"])
            .series([
                AASeriesElement()
                    .name("Moderate")
                    .data(moderateCoughData.map{ $0.value}),
                AASeriesElement()
                    .name("Severe")
                    .data(severeCoughData.map{ $0.value}),
            ])
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        return aaChartView
    }
}
