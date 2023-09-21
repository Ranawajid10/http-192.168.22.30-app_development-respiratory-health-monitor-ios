//
//  WeeklyCoughsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI

struct WeeklyCoughsView: View {
    
    @ObservedObject var dashboardVM:DashboardVM
    @Binding var totalCoughCount:Int
    @Binding var totalTrackedHours:Double
    @Binding var coughsPerHour:Int
    @Binding var allCoughList:[Cough]
    
    @State private var selectedDate = Date()
    
    @State var moderateTimeData: [String: Int] = [:]
    @State var severeTimeData: [String: Int] = [:]
    
    @State var sortedModerateTimeDataDictionary: [(key: String, value: Int)]  = []
    @State var sortedSevereTimeDataDictionary: [(key: String, value: Int)] = []
    
    @State var userData = LoginResult()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                    
                    DaySelectionView(selectedDate: $selectedDate)
                    
                    HourlyReportView(totalCoughCount: $totalCoughCount, totalTrackedHours: $totalTrackedHours, coughsPerHour: $coughsPerHour)
                    
                    
                    HourlyCoughGraph()
                    
                    
                    DailyGraphView(moderateCoughData: $sortedModerateTimeDataDictionary, severeCoughData: $sortedSevereTimeDataDictionary)
                        .frame(height: 350)
                    
                    
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
                        
                        if(userData.age==nil && userData.gender==nil && userData.ethnicity==nil){
                         
                            BecomeVolunteerView(dashboardVM: dashboardVM, allCoughList: $allCoughList)
                                .environment(\.managedObjectContext, viewContext)
                            
                        }else{
                            
                            VolunteerParticipationView()
                                .environment(\.managedObjectContext, viewContext)
                                .onAppear{
                                    
                                    dashboardVM.stopRecording()
                                    
                                }.onDisappear{
                                    
                                    if(!MyUserDefaults.getBool(forKey: Constants.isMicStopbyUser)){
                                        dashboardVM.startRecording()
                                    }
                                    
                                }
                            
                        }
                        
                    } label: {
                        
                        
                        Text("I want to volunteer")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width-60,height: 42)
                            .background(Color.appColorBlue)
                            .cornerRadius(40)
                        
                        
                    }.padding(.top)
                    
                    Spacer()
                    
                }
            }
        }.onAppear{
            
            userData = MyUserDefaults.getUserData() ?? LoginResult()
            
        }
    }
}

//struct WeeklyCoughsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeeklyCoughsView()
//    }
//}
