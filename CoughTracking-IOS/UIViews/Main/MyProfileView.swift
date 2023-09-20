//
//  MyProfileView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI

struct MyProfileView: View {
    
    
    
    @ObservedObject var myProfileVM = MyProfileVM()
  
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack {
                    
                    Image("dummy_person")
                        .resizable()
                        .frame(width: 120,height: 120)
                        .cornerRadius(60)
                    
                    Button {
                        
                        
                    } label: {
                        
                        ZStack{
                            
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 18,height: 18)
                                .foregroundColor(.black)
                            
                        }.frame(width: 32,height: 32)
                            .background(Color.white)
                            .cornerRadius(16)
                    }.padding(.top,-33)
                        .padding(.leading,60)
                    
                    Group{
                        
                        HStack{
                            
                            Text("Full name")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Full Name", text: $myProfileVM.userData.name)
                            .padding(.top,2)
                            .disabled(!myProfileVM.isEditAble)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Email Address")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Enter email", text: $myProfileVM.userData.email)
                            .padding(.top,2)
                            .disabled(true)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
//                    Group{
//                        HStack{
//
//                            Text("Password")
//                                .foregroundColor(.gray)
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
//
//                            Spacer()
//
//                        }.padding(.top)
//
//                        HStack{
//
//                            TextField("Enter password", text: $password)
//                                .padding(.top,2)
//                                .disabled(!isEditAble)
//
//                            NavigationLink {
//
//                                ChangePasswordView()
//
//                            } label: {
//
//                                Text("Change")
//                                    .foregroundColor(.appColorBlue)
//                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
//                                    .underline()
//
//                            }
//
//
//                        }
//
//                        Color.gray
//                            .frame(height: 1)
//
//
//                    }
                    
                    
                    Button {
                        
                        if(myProfileVM.isEditAble){
                            
                            myProfileVM.updateProfile()
                            
                        }else{
                            
                            withAnimation {
                                
                                myProfileVM.isEditAble.toggle()
                                
                            }
                            
                        }
                        
                    } label: {
                        
                        
                        Text(myProfileVM.isEditAble == true ? "Save" : "Edit" )
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                        
                        
                    }.frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                        .padding(.top)
                    
                }.padding(.horizontal)
            }
            
            if(myProfileVM.isLoading){
                
                LoadingView()
                
            }
            
        }.background(Color.screenBG)
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
    }
}
