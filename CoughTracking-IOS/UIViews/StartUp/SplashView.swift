//
//  SplashView.swift
//  CoughTracking-IOS
//
//  Created by ai4lyf on 11/08/2023.
//

import SwiftUI
import CoreData



struct SplashView: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @State private var animate = false
    @State private var goToNextScreen = false
    @State private var isActive = false
    
    @FetchRequest(entity: CoughBaseline.entity(), sortDescriptors: []) var coughBaselineFetchResult: FetchedResults<CoughBaseline>
    
    @State var offset = 0.0
    
    @State private var allValunteerCoughList: [VolunteerCough] = []
    @State private var uploadTrackingHoursList: [HoursUpload] = []

    
    var body: some View
    {
        VStack(spacing: 0) {
            
            if self.isActive{
                
                if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn)){
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)){
                        
                        DashboardView()
                            .environment(\.managedObjectContext, viewContext)
                        
                    }else if(!MyUserDefaults.getBool(forKey: Constants.isAllowSync)){
                        
                        AllowSyncStatsView(text: "Continue",allValunteerCoughList: $allValunteerCoughList ,uploadTrackingHoursList: $uploadTrackingHoursList)
                            .environment(\.managedObjectContext, viewContext)
                   
                    }else if(coughBaselineFetchResult.count == 0){
                        
                        BaselineView()
                            .environment(\.managedObjectContext, viewContext)
                        
                    }
                    
                    
                }else{
                    
                    GetStartedView()
                        .environment(\.managedObjectContext,viewContext)
                    
                }
               
                    
            }else{
                
                ZStack{
                    VStack{
                        Image("background-signs-splash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350, height: 400)
                            .alignmentGuide(.top) { dimension in
                                dimension[.top]
                            }
                            .scaleEffect(animate ? 1 : 0.3)
                            .opacity(animate ? 1 : 0.3)
                        
                        Image("coughapp-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 120)
                            .scaleEffect(animate ? 1 : 0.3)
                        
                        Image("background-signs-splash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350, height: 400)
                            .alignmentGuide(.bottom) { dimension in
                                dimension[.bottom]
                            }
                            .scaleEffect(animate ? 1 : 0.3)
                            .opacity(animate ? 1 : 0.3)
                        
                    }
                    
                   
                    VStack{
                        
                        Spacer()
                        
                        Text("POWERED BY")
                            .tracking(2)
                            .foregroundColor(Color.appColorBlue)
                            .font(.system(size: 9))
                            .fontWeight(.heavy)
                        
                        Image("ai4lyf")
                            .resizable()
                            .frame(width: 70, height: 20)
                        
                        
                    }.frame(height: UIScreen.main.bounds.height-100)
                    
                }
                
                
            }}
        
        .onAppear() {
            
            doAnimate()
        
        }.environment(\.managedObjectContext,viewContext)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
       
        
    }
    
    
    func doAnimate() {
        
        DispatchQueue.main.async {
            withAnimation(Animation.easeInOut(duration: 2.5)) {
                animate = true
            }
        }
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
               self.isActive = true
           }
        
    }
    
    
}


struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
