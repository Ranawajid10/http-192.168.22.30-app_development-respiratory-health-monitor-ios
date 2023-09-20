//
//  Functions.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation
import CoreData
import AVFoundation


class Functions{
    
    
    static  func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    static func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(hour * 3600)) // Convert hours to seconds
        return formatter.string(from: date)
    }
    
    static func convertToAudioBuffer(floatArray: [[Float]], sampleRate: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
        
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(floatArray[0].count))
        audioBuffer?.frameLength = AVAudioFrameCount(floatArray[0].count)
        
        if let buffer = audioBuffer {
            let floatBuffer = buffer.floatChannelData![0]
            for (index, sample) in floatArray[0].enumerated() {
                floatBuffer[index] = sample
            }
            return buffer
        }
        
        return nil
    }
    
}


@objc(MyCustomTransformer)
final class MyCustomTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSDictionary.self, NSNumber.self, NSString.self]
        // Add any other classes that your `[[Float]]` array might contain.
    }
}
