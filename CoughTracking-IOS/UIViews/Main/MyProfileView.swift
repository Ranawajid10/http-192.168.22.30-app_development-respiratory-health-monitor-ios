//
//  MyProfileView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI

struct MyProfileView: View {
    
    @State var fullName:String = ""
    @State var email:String = ""
    @State var password:String = ""
    
    
    @State var isEditAble = false
    
    
    
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
                        
                        TextField("Full Name", text: $fullName)
                            .padding(.top,2)
                            .disabled(!isEditAble)
                        
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
                        
                        TextField("Enter email", text: $email)
                            .padding(.top,2)
                            .disabled(!isEditAble)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Password")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        HStack{
                            
                            TextField("Enter password", text: $password)
                                .padding(.top,2)
                                .disabled(!isEditAble)
                            
                            NavigationLink {
                                
                                ChangePasswordView()
                                
                            } label: {
                                
                                Text("Change")
                                    .foregroundColor(.appColorBlue)
                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                                    .underline()
                                
                            }
                            
                            
                        }
                        
                        Color.gray
                            .frame(height: 1)
                        
                        
                    }
                    
                    
                    Button {
                        
                        withAnimation {
                            
                            isEditAble.toggle()
                            
                        }
                        
                    } label: {
                        
                        
                        Text(isEditAble == true ? "Save" : "Edit" )
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                        
                        
                    }.frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                        .padding(.top)
                    
                }.padding(.horizontal)
            }
        }.background(Color.screenBG)
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
    }
}
