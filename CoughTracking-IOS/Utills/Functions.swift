//
//  Functions.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 07/09/2023.
//

import Foundation
import CoreData
import AVFoundation
import UIKit
import SwiftUI


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
    
    static  func saveWAVFileToDocumentsDirectory(floatArray: [[Float]], sampleRate: Double, fileName: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try convertFloatAudioToWAV(floatArray: floatArray, sampleRate: sampleRate, filePath: filePath)
            return filePath
        } catch {
            throw error
        }
    }
    
    
    
    static  func convertFloatAudioToWAV(floatArray: [[Float]], sampleRate: Double, filePath: URL) throws {
        
        // Check if there is any audio data to write
        guard !floatArray.isEmpty else {
            print("Empty float array. Nothing to write.")
            return
        }
        
        // Define audio format
        let channelCount = 1  // Mono
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: AVAudioChannelCount(channelCount), interleaved: false)
        
        // Check if audio format is valid
        guard let format = audioFormat else {
            print("Invalid audio format.")
            return
        }
        
        do {
            // Create an AVAudioFile for writing
            let audioFile = try AVAudioFile(forWriting: filePath, settings: format.settings)
            
            // Create an AVAudioPCMBuffer
            let frameCount = AVAudioFrameCount(floatArray[0].count)  // Use the frame count from one of the channels
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
            buffer?.frameLength = frameCount
            
            // Loop through the elements of the floatArray and populate the buffer
            for i in 0..<Int(buffer!.frameLength) {
                buffer?.floatChannelData?[0][i] = floatArray[0][i]  // Assuming you're using the first channel
            }
            
            
            // Write the buffer to the audio file
            try audioFile.write(from: buffer!)
        } catch {
            print("Error writing audio file: \(error.localizedDescription)")
        }
    }
    
    
    static func changeBackIconTextColor(color:ColorResource){
        
        UINavigationBar.appearance().standardAppearance = {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Change title color
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] // Change large title color
            appearance.backgroundColor = UIColor(resource: color)
            
            // Customize back button text color
            appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor:UIColor(resource: color)]
            
            return appearance
        }()
        
        
    }
    
}


@objc(MyCustomTransformer)
final class MyCustomTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSDictionary.self, NSNumber.self, NSString.self]
        // Add any other classes that your `[[Float]]` array might contain.
    }
}
