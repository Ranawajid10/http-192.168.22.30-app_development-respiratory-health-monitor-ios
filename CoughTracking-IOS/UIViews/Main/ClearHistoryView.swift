//
//  ClearHistoryView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 24/08/2023.
//

import SwiftUI

struct ClearHistoryView: View {
    
    @State var isRangeExpended = false
    @State var showAlert = false
    
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Text("Time range")
                        .foregroundColor(.black)
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    Spacer()
                }
                
                DisclosureGroup("Select Range", isExpanded: $isRangeExpended) {
                    
                    ForEach(0..<Constants.clearHistoryList.count,id: \.self){ index in
                        
                        HStack {
                           
                            Text(Constants.clearHistoryList[index])
                                .foregroundColor(.black)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            .padding(.top)
                            
                            Spacer()
                        }
                                
                        
                    }
                    
                }.foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    .padding(.all,15)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.top)
                
                
                Button {
                    
                    showAlert.toggle()
                    
                } label: {
                    
                    
                    Text("Clear")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                    
                    
                }.frame(width: UIScreen.main.bounds.width-40,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                    .padding(.top,50)
                
                
                Spacer()
            }
        }.padding()
        .navigationTitle("Clear History")
        .background(Color.screenBG)
        .alert(isPresented: $showAlert) {
             Alert(title: Text("Clear History?"), message: Text("Are you sure you want to clear history?"), primaryButton: .default(Text("No"), action: {
                    print("Okay Click")
                }), secondaryButton: .default(Text("Yes")))
        }
    }
}

struct ClearHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClearHistoryView()
    }
}
