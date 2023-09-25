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
    
   
    var body: some View
    {
        VStack(spacing: 0) {
            
            if self.isActive{
                
                if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn)){
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)){
                        
                        DashboardView()
                            .environment(\.managedObjectContext, viewContext)
                        
                    }else if(!MyUserDefaults.getBool(forKey: Constants.isAllowSync)){
                        
                        AllowSyncStatsView(text: "Continue" )
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
                
                
                
            }}
        
        .onAppear() {
            
            animated()
            
            print(MyUserDefaults.getBool(forKey: Constants.isLoggedIn), Constants.isLoggedIn)
            print(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet), Constants.isBaseLineSet)
            print(coughBaselineFetchResult.count,"count")
        
        }.environment(\.managedObjectContext,viewContext)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
       
        
    }
    
    
    func saveData(){
        
//        print("aa")
//
//        let baseLine = CoughBaseline(context: viewContext)
//
//        baseLine.uid = "1"
//        baseLine.createdOn = String(DateUtills.getCurrentTimeInMilliseconds())
//
//        let floatArray: [Float] = [0.131, 0.3232, 1.4334, 0.4334, 0.3422, 0.434343]
////        let data = try? NSKeyedArchiver.archivedData(withRootObject: floatArray, requiringSecureCoding: false)
//
//        baseLine.setSegments(floatArray)
//
//        do {
//            try viewContext.save()
//            print("saved")
//        } catch {
//            // Handle the error
//            print("Error saving data: \(error.localizedDescription)")
//        }
        
    }
    
    func animated() {
//        withAnimation(Animation.easeInOut(duration: 2.5)) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            animate = true
        }
        delayedAction()
    }
    
    func delayedAction()
    {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            withAnimation
            {
                self.isActive = true
            }
        }
        
    }
}


struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
