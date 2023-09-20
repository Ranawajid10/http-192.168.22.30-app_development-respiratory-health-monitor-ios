//
//  VolunteerParticipationView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 24/08/2023.
//

import SwiftUI

struct VolunteerParticipationView: View {
    
    @State var isSelected = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("To ensure the privacy of out users, we are displaying all the coughs till now so that our users can hear them before uploading them to the cloud.")
                    .foregroundColor(Color.black)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                
                HStack{
                    
                    Button {
                        
                        
                    } label: {
                        
                        HStack{
                            
                            
                            Image("selection")
                                .resizable()
                                .frame(width: 24,height: 24)
                            
                            Text("Select all")
                                .foregroundColor(.appColorBlue)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            
                        }
                        
                    }.padding(.leading,10)
                        .padding(.top,30)
                    
                    Spacer()

                    
                }
                
                ScrollView(showsIndicators: false) {
                    ForEach(0..<20){ index in
                        
                        VStack{
                            
                            HStack {
                                Button {
                                    
                                    isSelected.toggle()
                                    
                                } label: {
                                    
                                    HStack{
                                        
                                        
                                        Image(isSelected == false ? "checked" : "unchecked")
                                            .resizable()
                                            .frame(width: 24,height: 24)
                                            .foregroundColor(Color.appColorBlue)
                                        
                                        Text("2023-08-23")
                                            .foregroundColor(.appColorBlue)
                                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                        
                                        
                                    }
                                    
                            }
                                Spacer()
                                
                            }
                            
                           
                            
                            HStack{
                                
                                Text("11:01:57")
                                    .foregroundColor(Color.black)
                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                
                                
                                HStack {
                                    
                                    Button {
                                        
                                        
                                    } label: {
                                        
                                        Image("play")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(Color.white)
                                        
                                    }.frame(width: 32,height: 32)
                                        .background(Color.appColorBlue)
                                        .cornerRadius(16)
                                    
                                    
                                    Image("waveform")
                                    
                                }.padding(.all,8)
                                .background(Color.white)
                                .cornerRadius(24)
                                .padding(.leading)

                               Spacer()
                                
                                Button {
                                    
                                    
                                } label: {
                                    
                                    Image(systemName: "ellipsis")
                                        .rotationEffect(Angle(degrees: 90))
                                        .foregroundColor(Color.appColorBlue)
                                    
                                }

                                
                            }
                            
                            
                        }
                        
                        
                    }.padding(.horizontal,5)
                    
                }.padding(.top,32)
                
                Button {
                    
                    
                    
                } label: {
                    
                    
                    Text("Donate Samples")
                        .foregroundColor(Color.white)
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    
                    
                }.frame(width: UIScreen.main.bounds.width-40,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
                
            }
        }.padding()
            .background(Color.screenBG)
            .navigationTitle("Volunteer Participation")
    }
}

struct VolunteerParticipationView_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerParticipationView()
    }
}
