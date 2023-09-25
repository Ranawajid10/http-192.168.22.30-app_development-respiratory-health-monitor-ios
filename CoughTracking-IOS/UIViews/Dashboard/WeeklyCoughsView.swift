//
//  WeeklyCoughsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI
import AAInfographics

struct WeeklyCoughsView: View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var allCoughList:[Cough]
    @Binding var hourTrackedList:[CoughTrackingHours]
    
    var weekOfDayArray = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"]
    
    @State var totalCoughCount:Int = 0
    @State var totalTrackedHours:Double = 0.0
    @State var coughsPerHour:Int = 0
    
    @State private var selectedDate = Date()
    @State var currentWeekRange: (start: Date, end: Date)? = nil
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State  var weekRangeText = ""
    
    
    
    @State var moderateTimeData: [String: Int] = [:]
    @State var severeTimeData: [String: Int] = [:]
    
    @State var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @State var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @State var userData = LoginResult()
    
    @State var changeGraph:Int = 0
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                    
                    WeeklySelectionView(selectedDate: $selectedDate,startDate: $startDate,endDate: $endDate, weekRangeText: $weekRangeText)
                    
                    HourlyReportView(totalCoughCount: $totalCoughCount, totalTrackedHours: $totalTrackedHours, coughsPerHour: $coughsPerHour)
                    
                    
                    HourlyCoughGraph()
                    
                    
                    WeeklyGraphView(moderateCoughData: $sortedModerateTimeDataDictionary, severeCoughData: $sortedSevereTimeDataDictionary)
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
            
        }).onAppear{
            
            userData = MyUserDefaults.getUserData() ?? LoginResult()
            getGraphData()
            
        }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            
            getGraphData()
            
        }
    }
    
    
    func getGraphData() {
        // Get the start and end dates of the current week
        currentWeekRange = DateUtills.getCurrentWeekRange(date: selectedDate)
        startDate = currentWeekRange?.start ?? Date()
        endDate = currentWeekRange?.end ?? Date()

        weekRangeText = DateUtills.dateRangeText(startDate: startDate, endDate: endDate)

        let (currentDateCoughs, _) = getCurrentWeekCoughs()

        totalCoughCount = currentDateCoughs.count
        
        calculateCurrentCoughHours()

        moderateTimeData.removeAll()
        severeTimeData.removeAll()

        // Initialize the dictionary with the days of the week as keys
        for day in weekOfDayArray {
            moderateTimeData[day, default: 0] = 0
            severeTimeData[day, default: 0] = 0
        }

        for cough in currentDateCoughs {
            guard let coughDate = cough.date,
                  let coughPower = cough.coughPower else {
                continue
            }

            let coughDate1 = DateUtills.stringToDate(date: coughDate, dateFormat: DateFormats.dateFormat1)
            let weekOfDay = DateUtills.getDayOfWeek(dateString: coughDate, dateFormat: DateFormats.dateFormat1)

            // Check if the cough date is within the specified date range
            if coughDate1 >= startDate && coughDate1 <= endDate {
                if let dayValue = weekOfDayArray.firstIndex(of: weekOfDay) {
                    let dayKey = weekOfDayArray[dayValue]
                    if coughPower == "moderate" {
                        moderateTimeData[dayKey, default: 0] += 1
                    } else if coughPower == "severe" {
                        severeTimeData[dayKey, default: 0] += 1
                    }
                }
            }
        }

        // Create a new dictionary with sorted keys and their corresponding values
        sortedModerateTimeDataDictionary.removeAll()
        sortedSevereTimeDataDictionary.removeAll()

        let moderateList = moderateTimeData.sorted { v1, v2 in
            return weekOfDayArray.firstIndex(of: v1.key) ?? 0 < weekOfDayArray.firstIndex(of: v2.key) ?? 0
        }

        sortedModerateTimeDataDictionary = moderateList

        let severeList = severeTimeData.sorted { v1, v2 in
            return weekOfDayArray.firstIndex(of: v1.key) ?? 0 < weekOfDayArray.firstIndex(of: v2.key) ?? 0
        }

        sortedSevereTimeDataDictionary = severeList

        changeGraph += 1
    }


    
    
    func calculateCurrentCoughHours(){
        
        totalTrackedHours = 0
        coughsPerHour = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
//        let startDateString = dateFormatter.string(from: startDate)
//        let endDateString = dateFormatter.string(from: endDate)
        
        var totalSeconds = 0.0
        
        for second in hourTrackedList {
            
            let trackDate = dateFormatter.date(from: second.date ?? "") ??  Date()
            
            if trackDate >= startDate && trackDate <= endDate {
                
                totalSeconds+=second.secondsTrack
                
            }
            
        }
        
        
        let hours =  totalSeconds/3600.0
        
       
        
        if(hours<1){
            
            totalTrackedHours = 1
            
        }else{
            
            totalTrackedHours =  totalSeconds/3600.0
            
        }
        
        
    
        
        coughsPerHour = totalCoughCount / Int(totalTrackedHours)
        
        print("totalSeconds",totalSeconds,"--hours",hours,"--coughsPerHour",coughsPerHour,"--totalCoughCount",totalCoughCount,"--totalTrackedHours",totalTrackedHours)
        
    }
    
    
    func getCurrentWeekCoughs() -> ([Cough],[String]){
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

//        var star
        print("startDate",startDate,"-----","endDate",endDate)
//
//        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            let trackDate = dateFormatter.date(from: cough.date ?? "") ??  Date()
            
            if trackDate >= startDate && trackDate <= endDate {
                
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
                
                
                coughTimes.append(coughTime)
                currentDateCoughsList.append(cough)
                
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
}


struct WeeklySelectionView: View {
    
    @Binding var selectedDate:Date
    @Binding var startDate:Date
    @Binding var endDate:Date
    
    @Binding var weekRangeText:String
    
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
            
            //            Text(isToday(selectedDate) ? "Today" : dateFormatter.string(from: selectedDate))
            Text(weekRangeText)
//                .onAppear{
//
//                    let currentWeekRange = getCurrentWeekRange(date: selectedDate)
//                    startDate = currentWeekRange.start
//                    endDate = currentWeekRange.end
//
//                    weekRangeText = dateRangeText(startDate: startDate, endDate: endDate)
//
//                }.id(selectedDate)
                
            
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
        
        let date = selectedDate
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
        if tomorrow <= Date() {
            selectedDate = DateUtills.getNextWeekMonday( selectedDate)
        }
        
        
    }
    
    func previous(){
        
        
        selectedDate = DateUtills.getPreviousWeekMonday(selectedDate)
        
        
    }
    
    
    
    
   
    
    
   
}


struct WeeklyGraphView: UIViewRepresentable {
    
    @Binding var moderateCoughData: [(key: String, value: Int)]
    @Binding var severeCoughData: [(key: String, value: Int)]
    
    func updateUIView(_ uiView: AAChartView, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> AAChartView {
        let aaChartView = AAChartView()
        
        let aaChartModel = AAChartModel()
            .animationType(.bounce)
            .chartType(.column)
            .stacking(.normal)
            .legendEnabled(false)
            .borderRadius(10)
            .dataLabelsEnabled(true)
            .categories(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"])
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





//struct WeeklyCoughsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeeklyCoughsView()
//    }
//}
