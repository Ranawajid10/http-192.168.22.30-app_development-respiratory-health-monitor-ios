//
//  ChangePasswordView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @State var oldPassword = ""
    @State var newPassword = ""
    @State var confirmPassword = ""
    
    @State var isSecure = false
    
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    
                    Group{
                        HStack{
                            
                            Text("Password")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        HStack{
                            
                            if(isSecure){
                                
                                SecureField("Enter current password", text: $oldPassword)
                                    .padding(.top,2)
                                
                            }else{
                                
                                TextField("Enter current password", text: $oldPassword)
                                    .padding(.top,2)
                                
                            }
                            
                            
                            Button {
                                
                                withAnimation {
                                    
                                    isSecure.toggle()
                                    
                                }
                                
                            } label: {
                                
                                Image(systemName: isSecure == false ? "eye" : "eye.slash")
                                    .foregroundColor(.black)
        
                                
                            }
                            
                            
                        }
                        
                        Color.gray
                            .frame(height: 1)
                        
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("New Password")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Enter new password", text: $newPassword)
                            .padding(.top,2)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Confirm New Password")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Confirm new password", text: $newPassword)
                            .padding(.top,2)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    
                }.padding(.horizontal)
            }
        }.navigationTitle("Change Password")
            .toolbar {
                
                ToolbarItem(placement:.confirmationAction) {
                    
                    Button {
                        
                        
                    } label: {
                        
                        Text("Save")
                            .foregroundColor(Color.appColorBlue)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        
                    }

                    
                    
                }
                
            }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
