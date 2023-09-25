//
//  UserReportView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI

struct UserReportView: View {
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    
                    Image("report")
                        .resizable()
                        .frame(width: 24,height: 24)
                    
                    Text("Your Cough Report")
                        .foregroundColor(.black)
                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                    
                    Spacer()
                    
                }
                
                
                Text("Your report will show a graph of your coughs over a period of one, two or three months.")
                    .foregroundColor(.darkBlue)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                    .padding(.horizontal,22)
                
                
                Button {
                    
                    
                } label: {
                    
                    
                    HStack {
                        
                        Image("downloads")
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text("Download PDF")
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                            .foregroundColor(Color.white)
                    }
                    
                    
                }.frame(width: UIScreen.main.bounds.width-60,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                    .padding(.top)
                
                
                Spacer()
                
            }.padding()
            
        }.navigationTitle("User Report")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserReportView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportView()
    }
}
