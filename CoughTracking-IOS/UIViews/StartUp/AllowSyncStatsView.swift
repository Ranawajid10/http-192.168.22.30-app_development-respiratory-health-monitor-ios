//
//  AllowSyncStatsView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/09/2023.
//

import SwiftUI

struct AllowSyncStatsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var text:String
    @State var isAutoDonate = true
    @State var isAutoSyncOn = false
    @State var isShareWithDoctor = false
    @State var isDonateForResearch = false
    @State var goNext = false
    @State var saved = false
    @State var shareWithDoctor = Constants.syncOptionsList[1]
    @State var donateForResearch = Constants.syncOptionsList[1]
    
    @State private var toast: FancyToast? = nil
    
    
    var body: some View {
        
        ZStack{
            
            VStack{
                
                Toggle(isOn: $isAutoSyncOn) {
                    
                    Text("Auto Syncronization")
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        .foregroundColor(Color.black)
                    
                }.padding(.trailing)
                    .tint(Color.appColorBlue)
                
                if(isAutoSyncOn){
                    
                    HStack {
                        
                        Text("Data Access Control")
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 18))
                            .foregroundColor(Color.black90)
                        
                        Spacer()
                        
                    }.padding(.top,32)
                    
                    
                    Toggle(isOn: $isShareWithDoctor) {
                        
                        HStack{
                            
                            Text("Share with you Doctor")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(Color.black)
                            
                            Button {
                                
                            } label: {
                                
                                Image(systemName: "info.circle")
                                
                            }
                            
                            
                        }
                    }.padding(.trailing)
                        .tint(Color.appColorBlue)
                        .padding(.top,8)
                    
                    if(isShareWithDoctor){
                        RadioButtonGroup(items: Constants.syncOptionsList, selectedId: shareWithDoctor) { selected in
                            
                            shareWithDoctor = selected
                            
                        }
                    }
                    
                    
                    Toggle(isOn: $isDonateForResearch) {
                        
                        HStack {
                            
                            Text("Donate for research and product improvement")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .foregroundColor(Color.black)
                            
                            
                            Button {
                                
                            } label: {
                                
                                Image(systemName: "info.circle")
                                
                            }.padding(.bottom)
                            
                        }
                        
                    }.padding(.trailing)
                        .tint(Color.appColorBlue)
                        .padding(.top,24)
                    
                    if(isDonateForResearch){
                        RadioButtonGroup(items: Constants.syncOptionsList, selectedId: donateForResearch) { selected in
                            
                            donateForResearch = selected
                            
                        }
                    }
                    
                    
                    Spacer()
                    
                    HStack{
                        
                        Button {
                            
                            
                            withAnimation {
                                
                                isAutoDonate.toggle()
                                
                            }
                            
                        } label: {
                            
                            HStack{
                                
                                Image(isAutoDonate ? "unchecked" : "checked")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                
                                Text("Auto donate, Don’t ask again")
                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                    .foregroundColor(Color.black)
                                
                            }
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                else{
                    
                    
                    Spacer()
                    
                }
                
                Button {
                    
                   
                    
                    if(MyUserDefaults.getBool(forKey: Constants.isBaseLineSet)  ){
                       
                        MyUserDefaults.saveBool(forKey: Constants.isAutoSync, value: isAutoSyncOn)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoDonate, value: isAutoDonate)
                        MyUserDefaults.saveBool(forKey: Constants.isShareWithDoctor, value: isShareWithDoctor)
                        MyUserDefaults.saveString(forKey: Constants.shareWithDoctor, value: shareWithDoctor)
                        MyUserDefaults.saveBool(forKey: Constants.isDonateForResearch, value: isDonateForResearch)
                        MyUserDefaults.saveString(forKey: Constants.donateForResearch, value: donateForResearch)
                        
                        saved = true
                        
                    }else{
                        
                        MyUserDefaults.saveBool(forKey:Constants.isAllowSync, value: true)
                        MyUserDefaults.saveBool(forKey:Constants.isBaseLineSet, value: false)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoSync, value: isAutoSyncOn)
                        MyUserDefaults.saveBool(forKey: Constants.isAutoDonate, value: isAutoDonate)
                        MyUserDefaults.saveBool(forKey: Constants.isShareWithDoctor, value: isShareWithDoctor)
                        MyUserDefaults.saveString(forKey: Constants.shareWithDoctor, value: shareWithDoctor)
                        MyUserDefaults.saveBool(forKey: Constants.isDonateForResearch, value: isDonateForResearch)
                        MyUserDefaults.saveString(forKey: Constants.donateForResearch, value: donateForResearch)
                        
                        goNext = true
                        
                    }
                    
                } label: {
                    
                    
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                    
                }
                .padding(.top,24)
                
                
            }
            .padding()
            
        }
        .toastView(toast: $toast)
        .navigationTitle("Data Sync")
            .background(Color.screenBG)
            .environment(\.managedObjectContext,viewContext)
            .navigationDestination(isPresented: $goNext) {
                
                BaselineView()
                    .environment(\.managedObjectContext,viewContext)
                
            }.onChange(of: isAutoSyncOn, perform: { newValue in
                if(!newValue){
                    
                    withAnimation {
                        isShareWithDoctor = false
                        isDonateForResearch = false
                    }
                    
                }
            })
            .onAppear{
                
                
                if(MyUserDefaults.getBool(forKey: Constants.isLoggedIn) && MyUserDefaults.getBool(forKey: Constants.isBaseLineSet) ){
                    
                    
                    isAutoDonate = MyUserDefaults.getBool(forKey: Constants.isAutoDonate)
                    isAutoSyncOn = MyUserDefaults.getBool(forKey: Constants.isAutoSync)
                    isShareWithDoctor = MyUserDefaults.getBool(forKey: Constants.isShareWithDoctor)
                    isDonateForResearch = MyUserDefaults.getBool(forKey: Constants.isDonateForResearch)
                    
                    
                    if let index = Constants.syncOptionsList.firstIndex(of: MyUserDefaults.getString(forKey: Constants.shareWithDoctor)) {
                       
                        
                        shareWithDoctor = Constants.syncOptionsList[index]
                        
                    }
                    
                    
                    if let index1 = Constants.syncOptionsList.firstIndex(of: MyUserDefaults.getString(forKey: Constants.donateForResearch)) {
                       
                        
                        donateForResearch = Constants.syncOptionsList[index1]
                        
                    }
                    
                    
                    
                }
                
                
            }.onChange(of: saved, perform: { newValue in
                if(newValue){
                    
                    toast = FancyToast(type: .success, title: "Success", message: "Data sync saved successfully")
                    saved = false
                    
                }
                
            })
    }
}

struct AllowSyncStatsView_Previews: PreviewProvider {
    static var previews: some View {
        AllowSyncStatsView(text: "Continue")
    }
}



