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
    @Binding var hourTrackedList:[TrackedHours]
    
   
    @StateObject var weeklyCoughVM = WeeklyCoughVM()
    
   
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                    
                    WeeklySelectionView(weeklyCoughVM: weeklyCoughVM)
                    
                    HourlyReportView(totalCoughCount: $weeklyCoughVM.totalCoughCount, totalTrackedHours: $weeklyCoughVM.totalTrackedHours, coughsPerHour: $weeklyCoughVM.coughsPerHour)
                    
                    
                    HourlyCoughGraph()
                    
                    
                    WeeklyGraphView(moderateCoughData: $weeklyCoughVM.sortedModerateTimeDataDictionary, severeCoughData: $weeklyCoughVM.sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                        .id(weeklyCoughVM.changeGraph)
                    
                    HStack{
                        
                        Spacer()
                        
                        Text("Time (24 hrs)")
                            .foregroundColor(Color.appColorBlue)
                            .font(.system(size: 14))
                            .padding(.trailing)
                        
                    }
                    
                    if(!MyUserDefaults.getBool(forKey: Constants.isAutoDonate)){
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
                            
                            AllowSyncStatsView(text: "Save",allValunteerCoughList: $dashboardVM.valunteerCoughList ,uploadTrackingHoursList: $dashboardVM.uploadTrackingHoursList)
                                .environment(\.managedObjectContext, viewContext)
//                            if(userData.age==nil && userData.gender==nil && userData.ethnicity==nil){
//
//                                BecomeVolunteerView(dashboardVM: dashboardVM, allCoughList: $allCoughList)
//                                    .environment(\.managedObjectContext, viewContext)
//
//                            }else{
//
//                                VolunteerParticipationView(dashboardVM: dashboardVM)
//                                    .environment(\.managedObjectContext, viewContext)
//
//
//                            }
                            
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
        }.onAppear{
            
            weeklyCoughVM.allCoughList.removeAll()
            weeklyCoughVM.hourTrackedList.removeAll()
            
            weeklyCoughVM.allCoughList = allCoughList
            weeklyCoughVM.hourTrackedList = hourTrackedList
            
            weeklyCoughVM.userData = MyUserDefaults.getUserData() ?? LoginResult()
            weeklyCoughVM.getGraphData()
            
        }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            
            weeklyCoughVM.allCoughList.removeAll()
            weeklyCoughVM.hourTrackedList.removeAll()
            
            weeklyCoughVM.allCoughList = allCoughList
            weeklyCoughVM.hourTrackedList = hourTrackedList
            
            weeklyCoughVM.getGraphData()
            
        }
    }
    
    
    
}


struct WeeklySelectionView: View {
    
    @ObservedObject var weeklyCoughVM:WeeklyCoughVM
//    @Binding var selectedDate:Date
//    @Binding var startDate:Date
//    @Binding var endDate:Date
    
//    @Binding var weekRangeText:String
    
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
                    
                    if(!weeklyCoughVM.isLoading){
                        weeklyCoughVM.previous()
                    }
                    
                    
                }
                
            } label: {
            
                if(weeklyCoughVM.isLoading && weeklyCoughVM.loaderPos == 1){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                    
                }
                
            }.frame(width: 20,height: 20)
            
            Spacer()
            
            //            Text(isToday(selectedDate) ? "Today" : dateFormatter.string(from: selectedDate))
            Text(weeklyCoughVM.weekRangeText)
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
                    
                    if(!weeklyCoughVM.isLoading){
                        weeklyCoughVM.next()
                    }
                    
                }
                
            } label: {
                
                if(weeklyCoughVM.isLoading && weeklyCoughVM.loaderPos == 0){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.black)
                    
                }
                
            }.frame(width: 20,height: 20)
                .disabled(Calendar.current.isDateInTomorrow(weeklyCoughVM.selectedDate))
            
        }
        .padding(.horizontal, 32)
       
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
