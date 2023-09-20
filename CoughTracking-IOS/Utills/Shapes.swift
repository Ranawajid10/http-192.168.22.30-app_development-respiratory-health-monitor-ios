//
//  Shapes.swift
//  CoughTracking-IOS

//  Created by Ali Rizwan on 22/08/2023.
//

import SwiftUI


struct BubbleView: View {
    var selectedIndex: Int
    var tabCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color.appColorBlue)
                .frame(width: geometry.size.width / CGFloat(tabCount), height: geometry.size.height)
                .offset(x: CGFloat(selectedIndex) * geometry.size.width / CGFloat(tabCount))
        }
    }
}



struct VerticalDashedLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let dashWidth: CGFloat = 4
                let dashSpacing: CGFloat = 1
                let numDashes = Int(geometry.size.height / (dashWidth + dashSpacing))
                
                for i in 0..<numDashes {
                    let yOffset = CGFloat(i) * (dashWidth + dashSpacing)
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: yOffset))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: yOffset + dashWidth))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .frame(width: 1)
        }.frame(width: 2)
    }
}

