//
//  CustomViews.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation
import SwiftUI



struct LoadingView: View {
    var body: some View {
        
        ZStack{
            
            Color.gray.opacity(0.5).ignoresSafeArea(.all)
            
            
            ZStack{
                
                ProgressView().tint(Color.white)
                
                
            }.frame(width: 60, height: 60)
                .background(Color.black.opacity(90))
                .cornerRadius(8)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.5))
        .onAppear {
            
            UIApplication.shared.endEditing()
            
        }
        
        
    }
}


struct CustomProgressViewStyle: ProgressViewStyle {
    var color: Color = .blue // Change this to the desired color
    
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .foregroundColor(color)
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.endEditing()            }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct NoAlertView: View {
    
    var action: () -> Void
    
    var body: some View {
        VStack {
            
            
            
            Text("No Internet")
                .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 24))
                .padding(.top)
            
            Text("You’re not connected to internet. Please connect and try again.")
                .multilineTextAlignment(.center)
                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                .padding(.top)
            
            
            Image("no_internet")
                .resizable()
                .frame(width: 146,height: 167)
                .padding(.top)
            
            
            
            
            Button {
                
                
                
            } label: {
                
                
                Text("Retry")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                
                
            }.frame(width: UIScreen.main.bounds.width-150,height: 42)
                .background(Color.appColorBlue)
                .cornerRadius(40)
                .padding()
                .padding(.top,50)
            
            
            
            
        }
        .frame(width: UIScreen.main.bounds.width-100)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


