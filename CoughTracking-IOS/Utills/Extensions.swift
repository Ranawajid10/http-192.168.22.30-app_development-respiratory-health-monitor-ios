//
//  Extensions.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 22/08/2023.
//

import Foundation
import SwiftUI

extension Color {
    static let screenBG = Color("screen_bg")
    static let appColorBlue = Color("app_color_blue")
    static let greyColor = Color("greycolor_text")
    static let lightBlue = Color("light_blue")
    static let skyBlue = Color("sky_blue")
    static let black90 = Color("black_90")
    static let darkBlue = Color("dark_blue")
    static let grayBorder = Color("gray_border")
}


extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTap())
    }
}


extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastModifier(toast: toast))
    }
}
extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}


extension Notification.Name {
    static let audioPlayerProgressNotification = Notification.Name("AudioPlayerProgressNotification")
}



