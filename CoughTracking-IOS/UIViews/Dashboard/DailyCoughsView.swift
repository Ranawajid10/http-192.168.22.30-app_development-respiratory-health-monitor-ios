//
//  DailyCoughsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI
import AAInfographics

struct DailyCoughsView: View {
    
    @Binding var totalCoughCount:Int
    @Binding var totalTrackedHours:Double
    @Binding var coughsPerHour:Int
    @Binding var allCoughList:[Cough]
    
    var array = ["00:00", "02:00", "04:00", "06:00", "08:00", "10:00",
                 "12:00", "14:00", "16:00", "18:00", "20:00", "23:00"]
    
    @State private var selectedDate = Date()
    
    @State var moderateTimeData: [String: Int] = [:]
    @State var severeTimeData: [String: Int] = [:]
    
    @State var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @State var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @State var changeGraph:Int = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                    
                    DaySelectionView(selectedDate: $selectedDate)
                    
                    HourlyReportView(totalCoughCount: $totalCoughCount, totalTrackedHours: $totalTrackedHours, coughsPerHour: $coughsPerHour)
                   
                    
                    HourlyCoughGraph()
                    
                    
                    DailyGraphView(moderateCoughData: $sortedModerateTimeDataDictionary, severeCoughData: $sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                        .id(changeGraph)
                    
                    
                    //            Color.white
                    //                .frame(height: 173)
                    
                    
                    HStack{
                        
                        Spacer()
                        
                        Text("Time (24 hrs)")
                            .foregroundColor(Color.appColorBlue)
                            .font(.system(size: 14))
                            .padding(.trailing)
                        
                    }
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
                        
                        BecomeVolunteerView()
                        
                    } label: {
                        
                        
                        Text("I want to volunteer")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                        
                        
                    }.frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                        .padding(.top)
                    
                    Spacer()
                    
                }
            }
        }.onChange(of: selectedDate, perform: { newValue in
            
            getGraphData()
            
        }).onAppear{
            
            getGraphData()
            
        }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
           
            getGraphData()
            
        }
    }
    
    func getGraphData(){
        
        let (currentDateCoughs,times) = getCurrentDayCoughs()
        
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
            
            print("coughTime",coughTime)
            // Extract the minutes part from the cough time (e.g., "11:42:54" -> "42")
            let minutes = coughTime.dropLast(6)
            
            
            print("minutes",minutes)
            
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
            
            changeGraph+=1
            
//        }
        
        
        print("Daily Graph Data",currentDateCoughs.count,"---",times.count,"---Moderate---",sortedModerateTimeDataDictionary,"---Severe---",sortedSevereTimeDataDictionary)
        
        
    }
    
    func getCurrentDayCoughs() -> ([Cough],[String]){
        
        var currentDateCoughsList:[Cough] = []
        
        var coughTimes: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        
        for cough in allCoughList {
            
            if cough.date == dateString {
                
                
                
                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
              
                
                coughTimes.append(coughTime)
                currentDateCoughsList.append(cough)
                
                
            }
            
            
            
        }
        
        
        return (currentDateCoughsList,coughTimes)
    }
    
    
}

struct DailyGraphView: UIViewRepresentable {
    
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
            .categories(["00:00", "02:00", "04:00", "06:00", "08:00", "10:00",
                         "12:00", "14:00", "16:00", "18:00", "20:00", "23:00"])
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

//struct DailyCoughsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyCoughsView()
//    }
//}
