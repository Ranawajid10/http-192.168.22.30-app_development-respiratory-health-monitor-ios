//
//  BecomeVolunteerView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI

struct BecomeVolunteerView: View {
    
    @ObservedObject var becomeVolunteerVM = BecomeVolunteerVM()
    @State private var toast: FancyToast? = nil
    
    
    var body: some View {
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack {
                    
                    Text("Please provide the following inofrmation (This info is taken one time only):")
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    
                    Group{
                        HStack{
                            
                            Text("Age")
                                .foregroundColor(.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Enter age here", text: $becomeVolunteerVM.age)
                            .padding(.top,2)
                            .keyboardType(.numberPad)
                            .modifier(TextFieldMaxCharacterLimitModifier(text: $becomeVolunteerVM.age, limit: 3))
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Gender")
                                .foregroundColor(.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        DisclosureGroup(becomeVolunteerVM.genderDGText, isExpanded: $becomeVolunteerVM.isGenderExpended) {
                            
                            ForEach(0..<Constants.genderList.count,id: \.self){ index in
                                
                                HStack {
                                    
                                    Button {
                                        
                                        withAnimation {
                                            becomeVolunteerVM.genderDGText = Constants.genderList[index]
                                            becomeVolunteerVM.selectedGenderIndex = index
                                            becomeVolunteerVM.isGenderExpended.toggle()
                                        }
                                        
                                        
                                    } label: {
                                        
                                        
                                        Text(Constants.genderList[index])
                                            .foregroundColor(.black)
                                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                            .padding(.top)
                                        
                                    }
                                    
                                    
                                    Spacer()
                                }
                                
                                
                            }
                            
                        }.foregroundColor(.black)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            .padding(.top,2)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.top)
                            .onAppear{
                                
                                if(becomeVolunteerVM.selectedGenderIndex == -1){
                                    
                                    becomeVolunteerVM.genderDGText = "Enter gender"
                                    
                                }
                                
                            }
                        
                        //                        TextField("Enter gender", text: $becomeVolunteerVM.gender)
                        //                            .padding(.top,2)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Ethncity")
                                .foregroundColor(.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        
                        DisclosureGroup(becomeVolunteerVM.ethncity, isExpanded: $becomeVolunteerVM.isEthncityExpended) {
                            
                            ForEach(0..<Constants.ethnicityList.count,id: \.self){ index in
                                
                                HStack {
                                    
                                    Button {
                                        
                                        withAnimation {
                                            becomeVolunteerVM.ethncity = Constants.ethnicityList[index]
                                            becomeVolunteerVM.selectedEthncityIndex = index
                                            becomeVolunteerVM.isEthncityExpended.toggle()
                                        }
                                        
                                        
                                    } label: {
                                        
                                        
                                        Text(Constants.ethnicityList[index])
                                            .foregroundColor(.black)
                                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                            .padding(.top)
                                        
                                    }
                                    
                                    
                                    Spacer()
                                }
                                
                                
                            }
                            
                        }.foregroundColor(.black)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            .padding(.top,2)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.top)
                            .onAppear{
                                
                                if(becomeVolunteerVM.selectedEthncityIndex == -1){
                                    
                                    becomeVolunteerVM.ethncity = "Enter gender"
                                    
                                }
                                
                            }
                        
//                        TextField("Enter ethncity", text: $becomeVolunteerVM.ethncity)
//                            .padding(.top,2)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Medical Condition")
                                .foregroundColor(.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Enter if any?", text: $becomeVolunteerVM.medicalCondition)
                            .padding(.top,2)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        
                        becomeVolunteerVM.proceed()
                        
                    } label: {
                        
                        
                        Text("Proceed")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width-60,height: 42)
                            .background(Color.appColorBlue)
                            .cornerRadius(40)
                        
                    }
                    .padding(.top,24)
                    
                    
                    
                    
                    
                }.padding(.horizontal)
                
            }
            
        }.toastView(toast: $toast)
            .dismissKeyboardOnTap()
            .navigationTitle("Volunteer Participation")
            .onChange(of: becomeVolunteerVM.isError){ newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: becomeVolunteerVM.errorMessage)
                    
                }
                
            }.navigationDestination(isPresented: $becomeVolunteerVM.goNext) {
                
                VolunteerParticipationView()
                
            }.toolbar{
                
                ToolbarItem(placement: .primaryAction) {
                    
                    Button("Skip"){
                        
                        becomeVolunteerVM.goNext.toggle()
                        
                    }
                    
                }
                
            }
    }
}

struct BecomeVolunteerView_Previews: PreviewProvider {
    static var previews: some View {
        BecomeVolunteerView()
    }
}
