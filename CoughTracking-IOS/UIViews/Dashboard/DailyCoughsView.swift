//
//  DailyCoughsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI
import AAInfographics

struct DailyCoughsView: View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var allCoughList:[Cough]
    @Binding var hourTrackedList:[TrackedHours]
    
    @StateObject var dailyCoughVM = DailyCoughVM()
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    @State private var toast: FancyToast? = nil
    
    var body: some View {
        ZStack {
            
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    
                    DailyDaySelectionView(dailyCoughVM: dailyCoughVM)
                    
                    HourlyReportView(totalCoughCount: $dailyCoughVM.totalCoughCount, totalTrackedHours: $dailyCoughVM.totalTrackedHours, coughsPerHour: $dailyCoughVM.coughsPerHour)
                    
                    
                    HourlyCoughGraph()
                    
                    
                    DailyGraphView(moderateCoughData: $dailyCoughVM.sortedModerateTimeDataDictionary, severeCoughData: $dailyCoughVM.sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                        .id(dailyCoughVM.changeGraph)
                    
                    
                    //            Color.white
                    //                .frame(height: 173)
                    
                    
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
            
            
            
        }.toastView(toast: $toast)
            .onReceive(dailyCoughVM.$isError, perform:  { i in
                
                if(i){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: dailyCoughVM.errorMessage)
                    dailyCoughVM.isError = false
                    
                }
                
                
            }).onAppear{
                
                
                dailyCoughVM.allCoughList.removeAll()
                dailyCoughVM.hourTrackedList.removeAll()
                
                dailyCoughVM.allCoughList = allCoughList
                dailyCoughVM.hourTrackedList = hourTrackedList
                
                dailyCoughVM.userData = MyUserDefaults.getUserData() ?? LoginResult()
                
                dailyCoughVM.getGraphData()
                
            }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
                
                dailyCoughVM.allCoughList.removeAll()
                dailyCoughVM.hourTrackedList.removeAll()
                
                dailyCoughVM.allCoughList = allCoughList
                dailyCoughVM.hourTrackedList = hourTrackedList
                
                dailyCoughVM.getGraphData()
                
            }
    }
    
    
    
}


struct DailyDaySelectionView: View {
    
    @ObservedObject var dailyCoughVM:DailyCoughVM
    
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
                    
                    if(!dailyCoughVM.isLoading){
                        dailyCoughVM.previous()
                    }
                    
                }
                
            } label: {
                
                if(dailyCoughVM.isLoading && dailyCoughVM.loaderPos == 1){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                    
                }
                
            }.frame(width: 20,height: 20)
            
            
            Spacer()
            
            Text(dailyCoughVM.isToday(dailyCoughVM.selectedDate) ? "Today" : dateFormatter.string(from:dailyCoughVM.selectedDate))
            
            
            Spacer()
            
            Button {
                
                withAnimation {
                    
                    if(!dailyCoughVM.isLoading){
                        
                        dailyCoughVM.next()
                        
                    }
                    
                }
                
            } label: {
                
                if(dailyCoughVM.isLoading && dailyCoughVM.loaderPos == 0){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.black)
                    
                }
                
            }.frame(width: 20,height: 20)
                .disabled(Calendar.current.isDateInTomorrow(dailyCoughVM.selectedDate))
            
        }
        .padding(.horizontal, 32)
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
