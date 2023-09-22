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


struct NoInternetAlertView: View {
    
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
                
                action()
                
            } label: {
                
                
                Text("Retry")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width-150,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
                
            }.padding()
                .padding(.top,50)
            
            
            
            
        }.edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width-100)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


struct RadioButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let id: String
    let callback: (String)->()
    let selectedID : String
    let size: CGFloat
    let color: Color
    let textSize: CGFloat
    
    init(
        _ id: String,
        callback: @escaping (String)->(),
        selectedID: String,
        size: CGFloat = 20,
        color: Color = Color.primary,
        textSize: CGFloat = 16
    ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }
    
    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.selectedID == self.id ? "largecircle.fill.circle" : "circle")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                    .modifier(ColorInvert())
                Text(id)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: textSize))
                
                Spacer()
            }.foregroundColor(self.color)
        }
        .foregroundColor(self.color)
    }
}

struct ColorInvert: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.colorInvert()
            } else {
                content
            }
        }
    }
}

struct RadioButtonGroup: View {
    
    let items : [String]
    
    @State var selectedId: String = ""
    
    let callback: (String) -> ()
    
    var body: some View {
        VStack {
            ForEach(0..<items.count,id: \.self) { index in
                RadioButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
                    .padding(.top)
            }
        }
    }
    
    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}
