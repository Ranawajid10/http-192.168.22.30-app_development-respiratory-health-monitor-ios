//
//  Modifiers.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import Foundation
import SwiftUI
import Combine

struct LatoFontModifier: ViewModifier {
    var fontWeight: Font.Weight
    var fontSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Lato-Regular", size: fontSize))
            .fontWeight(fontWeight)
    }
}

struct TextFieldMaxCharacterLimitModifier: ViewModifier {
    @Binding private var text: String
    let limit: Int

    init(text: Binding<String>, limit: Int) {
        self._text = text
        self.limit = limit
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > limit {
                    text = String(newValue.prefix(limit))
                }
            }
    }
}
