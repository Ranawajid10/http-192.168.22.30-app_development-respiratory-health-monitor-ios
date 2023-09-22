//
//  GetStartedView.swift
//  CoughTracking-IOS
//
//  Created by ai4lyf on 11/08/2023.
//

import SwiftUI

struct GetStartedView: View{
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var navigateToLogin = false
    
    var body: some View{
        
        
        ZStack {
            
                VStack(spacing: 20) {
                    
                    Image("logosmall")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .alignmentGuide(.top) { dimension in
                            dimension[.top]
                        }
                    
                    Image("main_view_mid")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 130)
                        .padding(.top, 50)
                    
                    
                    Image("realtime_cough_text_getstartedsreen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 50)
                    
                    //                        Button(action: {
                    //                            // Handle the first button action
                    //
                    //
                    //                        }) {
                    //                            Image("ihavecode_btn")
                    //                                .resizable()
                    //                                .aspectRatio(contentMode: .fit)
                    //                                .frame(height: 50)
                    //                                .padding(.top, 100)
                    //                                .alignmentGuide(.bottom) { dimension in
                    //                                    dimension[.bottom]
                    //                                }
                    //                        }
                    //
                    //                        NavigationLink {
                    //
                    //                            LoginView()
                    //                                .environment(\.managedObjectContext,viewContext)
                    //
                    //                        } label: {
                    //                            Image("idonthavecode_btn")
                    //                                .resizable()
                    //                                .aspectRatio(contentMode: .fit)
                    //                                .frame(height: 50)
                    //                                .alignmentGuide(.bottom) { dimension in
                    //                                    dimension[.bottom]
                    //                                }
                    //                        }
                    
                    Spacer()
                    
                    NavigationLink {
                        
                        LoginView()
                            .environment(\.managedObjectContext,viewContext)
                        
                    } label: {
                        
                        Text("Continue")
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width-60,height: 42)
                            .background(Color.appColorBlue)
                            .cornerRadius(40)
                        
                    }.padding(.bottom)
                    
                    
                    
                    
                    
                }.environment(\.managedObjectContext,viewContext)
                    .padding()
                    .navigationTitle("")
                    .navigationBarBackButtonHidden()

        }
        
        
    }
    
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
