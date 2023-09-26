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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var allCoughList:[Cough]
    @Binding var hourTrackedList:[TrackedHours]
    
    @StateObject var hourlyCoughVM = HourlyCoughVM()
   
    
    
    var body: some View {
        
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    
                    HourlyDaySelectionView(hourlyCoughVM: hourlyCoughVM)
                    
                    HourlyReportView(totalCoughCount: $hourlyCoughVM.totalCoughCount, totalTrackedHours: $hourlyCoughVM.totalTrackedHours, coughsPerHour: $hourlyCoughVM.coughsPerHour)
                    
                    HourSelectionView(hourlyCoughVM: hourlyCoughVM)
                    
                    HourlyCoughGraph()
                    
                    
                    HourlyGraphView(moderateCoughData: $hourlyCoughVM.sortedModerateTimeDataDictionary, severeCoughData: $hourlyCoughVM.sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                        .id(hourlyCoughVM.changeGraph)
                    
                    
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
        }.environment(\.managedObjectContext,viewContext)
//            .onChange(of: selectedDate, perform: { newValue in
//                
//                getGraphData()
//                
//            })
//            .onChange(of: currentHour, perform: { newValue in
//                
//                getGraphData()
//                
//            })
            .onAppear{
                
                hourlyCoughVM.allCoughList.removeAll()
                hourlyCoughVM.hourTrackedList.removeAll()
                
                hourlyCoughVM.allCoughList = allCoughList
                hourlyCoughVM.hourTrackedList = hourTrackedList
                
                
                hourlyCoughVM.userData = MyUserDefaults.getUserData() ?? LoginResult()
                hourlyCoughVM.getGraphData()
                
            }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
                
                hourlyCoughVM.allCoughList.removeAll()
                hourlyCoughVM.hourTrackedList.removeAll()
                
                hourlyCoughVM.allCoughList = allCoughList
                hourlyCoughVM.hourTrackedList = hourTrackedList
                
                hourlyCoughVM.getGraphData()
                
            }
    }
    
  
    
}

//struct HourlyCoughsView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        HourlyCoughsView(totalCoughCount: <#Binding<Int>#>, totalTrackedHours: <#Binding<Int>#>, coughsPerHour: <#Binding<Int>#>)
//    }
//}

struct HourSelectionView: View {
    
    @ObservedObject var hourlyCoughVM:HourlyCoughVM
    
    
    var body: some View {
        
        HStack {
            
            
            Button {
                
                withAnimation {
                    
                    if(!hourlyCoughVM.isLoading){
                        hourlyCoughVM.previousHour()
                    }
                    
                }
                
            } label: {
                if(hourlyCoughVM.isLoading && hourlyCoughVM.loaderPos == 1){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                    
                }
            }
            
            
            
            Text(String(hourlyCoughVM.currentHour)+":00")
                .padding(.horizontal)
            
            
            
            
            
            Button {
                
                withAnimation {
                    
                    if(!hourlyCoughVM.isLoading){
                        hourlyCoughVM.nextHour()
                    }
                    
                }
                
            } label: {
                if(hourlyCoughVM.isLoading && hourlyCoughVM.loaderPos == 0){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.black)
                    
                }
            }
            
            
        }
        .padding(.horizontal, 32)
        .padding(.top,16)
    }
    
   
}

struct HourlyDaySelectionView: View {
    
    @ObservedObject var hourlyCoughVM:HourlyCoughVM
    
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
                    
                    if(!hourlyCoughVM.isLoading){
                        
                        hourlyCoughVM.previous()
                        
                    }
                    
                }
                
            } label: {
                
                if(hourlyCoughVM.isLoading && hourlyCoughVM.loaderPos == 3){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                    
                }
                
                
            }.frame(width: 20,height: 20)
            
            Spacer()
            
            Text(hourlyCoughVM.isToday(hourlyCoughVM.selectedDate) ? "Today" : dateFormatter.string(from: hourlyCoughVM.selectedDate))
            
            
            Spacer()
            
            Button {
                
                withAnimation {
                    
                    if(!hourlyCoughVM.isLoading){
                        
                        hourlyCoughVM.next()
                        
                    }
                   
                    
                }
                
            } label: {
                
                if(hourlyCoughVM.isLoading && hourlyCoughVM.loaderPos == 2){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.black)
                    
                }
                
            }.frame(width: 20,height: 20)
                .disabled(Calendar.current.isDateInTomorrow(hourlyCoughVM.selectedDate))
            
        }
        .padding(.horizontal, 32)
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
