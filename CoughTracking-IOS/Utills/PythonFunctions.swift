//
//  PythonFunctions.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 05/09/2023.
//

import Foundation
import SwiftUI
import AVFoundation
import PythonKit
import TensorFlowLite
import CoreML
import AudioToolbox
import Accelerate
import Combine


class PythonFunctions{
    
    
    static func calculateAdaptiveLoudness(loudness: Float, rspLoudness: Float, sensitivity: Float = 3.0) -> String {
        var severeRange: ClosedRange<Float>
        
        if rspLoudness <= rspLoudness + (rspLoudness / sensitivity) {
            severeRange = rspLoudness...rspLoudness + (rspLoudness / sensitivity)
        } else {
            severeRange = rspLoudness + (rspLoudness / sensitivity)...rspLoudness
        }
        
        print("[::]", rspLoudness, loudness, severeRange.lowerBound, severeRange.upperBound)
        
        if loudness > rspLoudness {
            return "severe"
        } else if loudness < severeRange.lowerBound && loudness > severeRange.upperBound {
            return "severe"
        } else if loudness < severeRange.upperBound {
            return "moderate"
        } else {
            return "unknown" // You may want to handle other cases as needed
        }
    }
    
    
    static func padder(data: [Float]) -> [Float] {
        if data.count <= 22016 {
            let padCount = 22016 - data.count
            let paddedData = data + Array(repeating: 0.0, count: padCount)
            return paddedData
        } else {
            let truncatedData = Array(data[0..<22016])
            return truncatedData
        }
    }
    
    //    static func padder(data: Float) -> [Float] {
    //        var paddedData = [Float](repeating: 0, count: 22016)
    //        paddedData[0] = data
    //        return paddedData
    //    }
    //
    
    static func computeTotalEnergy2(_ x: [Float], _ fs: Float) -> Float {
        
        let squaredAmplitudes = x.map { $0 * $0 }
        let totalEnergy = squaredAmplitudes.reduce(0.0, +)
        
        
        return totalEnergy
    }
    
    static func computeMaxSegmentEnergy(segments: [[Float]], fs: Float) -> Float {
        
        
        let segmentLoudness = segments.map { self.computeTotalEnergy2($0, fs) }
        let maxSegmentEnergy = segmentLoudness.max() ?? 0.0
        
        
        return maxSegmentEnergy
    }
    //    static func computeTotalEnergy2(_ x: [Float], _ fs: Float) -> Float {
    //
    //        let squaredAmplitudes = x.map { $0 * $0 }
    //        let totalEnergy = squaredAmplitudes.reduce(0.0, +)
    //
    //
    //        return totalEnergy
    //    }
    //
    //    static func computeMaxSegmentEnergy(segments: [[Float]], fs: Float) -> Float {
    //
    //
    //        let segmentLoudness = segments.map { self.computeTotalEnergy2($0, fs) }
    //        let maxSegmentEnergy = segmentLoudness.max() ?? 0.0
    //
    //
    //        return maxSegmentEnergy
    //    }
    
    static func coughSegmentInference(audioData: [Float], fs: Float,buffer: AVAudioPCMBuffer)->([[Float]],[Float])  {
        var segmentWav: [[Float]] = []
        var probs: [Float] = []
        var segments: [[Float]] = []
        var fsNew:Float = 0.0
        
        
        
        if let modelPath = Bundle.main.path(forResource: "segmented_final_model_weights_no_optimization", ofType: "tflite") {
            
            
            guard let interpreter = try? TensorFlowLite.Interpreter(modelPath: modelPath ) else {
                print("dsds")
                return (segmentWav,probs)
            }
            
            
            try! interpreter.allocateTensors()
            // Get input and output tensors
            //                        let inputDetails = try! interpreter.input(at: 0)
            //                        let outputDetails = try! interpreter.output(at: 0)
            
            
            try! interpreter.invoke()
            
            if !audioData.isEmpty {
                
                (segments,fsNew) = self.coughSegmenter(xOrig: audioData, fs: fs,buffer:buffer)
                
                print("segments count= ",segments.count," ----",fsNew)
                
                
                if(segments.count>0){
                    
                    
                    var counter = 0
                    
                    
                    for x in segments {
                        
                        let xPadder = self.padder(data: x)
                        
                        //                            print("xpadder",xPadder,"---",counter)
                        
                        //                            let inputData = [x]
                        
                        
                        //                            do{
                        //
                        let data = Data(buffer: UnsafeBufferPointer(start: xPadder, count: xPadder.count))
                        
                        try? interpreter.copy(data, toInputAt: 0)
                        
                        // Invoke the model
                        try? interpreter.invoke()
                        
                        guard let outputTensor = try? interpreter.output(at: 0) else {
                            fatalError("Error getting output data")
                        }
                        
                        //                            let outputSize = outputTensor.shape.dimensions.reduce(1, {x, y in x * y})
                        //                              let outputData =
                        //                                    UnsafeMutableBufferPointer<Float32>.allocate(capacity: outputSize)
                        //                              outputTensor.data.copyBytes(to: outputData)
                        let outputData = outputTensor.data
                        
                        //                        let outputDetails = try interpreter.output(at: 0)
                        //                        let outputTensorData = outputDetails.data
                        
                        //                        let finalData = Float(outputTensorData[0])
                        let finalData = Float(outputData[0])
                        
                        print("finalData",finalData,"---",counter)
                        
                        probs.append(finalData)
                        
                        
                        if finalData > 0.95 {
                            //                                    print("yes")
                            segmentWav.append(xPadder)
                        }
                        
                        //                            }catch{
                        //
                        //                                print("Error loading or invoking the model: \(error.localizedDescription)")
                        //
                        //                            }
                        
                        
                        counter+=1
                    }
                    
                }
                
                
                print("segment Wav count= ",segmentWav.count)
                
                //                return (segmentWav,probs)
                
                
                
                
                //                let sampleRate: Double = 22050 // Example sample rate
                //
                //                let fileName = "my_audio.wav"
                //
                //                do {
                //                    filePath = try saveWAVFileToDocumentsDirectory(floatArray: segments, sampleRate: sampleRate, fileName: fileName)
                //                    playWAVFile(filePath: filePath!)
                //
                //
                //                    gotSample = true
                //                    // Share the file using UIDocumentInteractionController
                //
                //
                //
                //                } catch {
                //                    print("Error: \(error.localizedDescription)")
                //                }
                
                
                
                
            }else{
                
                //                return (segmentWav,probs)
                
            }
            
        }
        
        return (segments,probs)
        
    }
    
    func computeTotalEnergy(_ x: [Float]) -> Float {
        let squaredAmplitudes = x.map { $0 * $0 }
        let totalEnergy = squaredAmplitudes.reduce(0, +)
        return totalEnergy
    }
    
    // Function to calculate power reference
    func calculatePowerReference(atPath path: String) -> Float {
        let url = URL(fileURLWithPath: path)
        let audioFile = try! AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false)
        let frameCount = UInt32(audioFile.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: frameCount)
        try! audioFile.read(into: buffer!)
        
        let x = Array(UnsafeBufferPointer(start: buffer!.floatChannelData?[0], count: Int(frameCount)))
        let totalEnergy = self.computeTotalEnergy(x)
        
        return totalEnergy
    }
    
    // Function to normalize audio
    static func normalizeAudio(_ audioArray: [Float]) -> [Float] {
        
        let maxAbsValue = audioArray.max(by: { abs($0) < abs($1) }) ?? 1.0
        if maxAbsValue > 0 {
            let normalizedArray = audioArray.map { $0 / maxAbsValue }
            return normalizedArray
        }
        
        return audioArray
    }
    
    // Function to calculate sound power level
    static func calculateSoundPowerLevel(power: Float, referencePower: Float) -> String {
        let soundPowerLevel = 10 * log10(power / referencePower)
        print("[::]", soundPowerLevel)
        
        if abs(soundPowerLevel) <= 6.0 {
            return "severe"
        } else if abs(soundPowerLevel) > 6.0 {
            return "moderate"
        }
        
        return ""
    }
    
    static func powerByAVFoundation(_ x: [Float], _ fs: Float,buffer: AVAudioPCMBuffer) -> Float {
        
        print("in powerByAVFoundation")
        
        let integratedLoudness = self.calculateLoudness(buffer)
        
        
        print("out powerByAVFoundation---",integratedLoudness)
        
        
        return integratedLoudness
    }
    
    static func dbScalerSwift(_ x: [Float], _ fs: Float,buffer: AVAudioPCMBuffer) -> [Float] {
        // Measure loudness using AVAudioEngine (you can use the powerByAVFoundation function from the previous example)
        
        print("in dbScalerSwift")
        let integratedLoudness = self.powerByAVFoundation(x, fs,buffer: buffer)
        
        print("Loudness: \(integratedLoudness)")
        
        var loudnessNormalizedAudio = x
        
        if integratedLoudness < -5 {
            // Calculate the sound increase by 50%
            let newLoudness = integratedLoudness + 5.0 // Increase loudness by 5 dB
            let scalingFactor = pow(10, (newLoudness - integratedLoudness) / 20.0)
            
            // Apply the scaling factor to each sample in the audio
            loudnessNormalizedAudio = x.map { $0 * Float(scalingFactor) }
        }
        
        return loudnessNormalizedAudio
    }
    
    // Main function for cough segmentation
    static func coughSegmenter(xOrig: [Float], fs: Float,buffer: AVAudioPCMBuffer) -> ([[Float]], Float) {
        print("in coughSegmenter")
        let xOrigNormalized = normalizeAudio(xOrig)
        let xDB = dbScalerSwift(xOrig, fs,buffer: buffer)
        // Calculate reference power using your logic (not implemented here)
        
        //        var coughSegments:[Float] = []
        //        var coughMask:[Bool]  = []
        
        let (coughSegments,_) = self.coughSegmentationNew(xDB, xOrigNormalized, fs)
        return (coughSegments, fs)
    }
    
    
    
    
    
    static func calculateLoudness(_ audioBuffer: AVAudioPCMBuffer) -> Float {
        // Implement your loudness calculation here using the provided audioBuffer.
        // You can use audio analysis techniques like RMS, dBFS, or other loudness metrics.
        
        // Example (RMS):
        let frameCount = AVAudioFrameCount(audioBuffer.frameLength)
        let channelData = audioBuffer.floatChannelData![0]
        
        var sum: Float = 0.0
        for i in 0..<Int(frameCount) {
            sum += pow(channelData[i], 2)
        }
        
        let rms = sqrt(sum / Float(frameCount))
        
        return 20 * log10(rms) // Convert RMS to dB
    }
    
    static func normalizeAudio(_ x: [Float], _ currentLoudness: Double, _ targetLoudness: Double) -> [Float] {
        let normalizationFactor = pow(10, (targetLoudness - currentLoudness) / 20.0)
        return x.map { $0 * Float(normalizationFactor) }
    }
    
    
    static func coughSegmentationNew(_ x: [Float], _ xReal: [Float], _ fs: Float) -> ([[Float]], [Bool]) {
        
        print("in coughSegmentationNew")
        let (coughSegments, coughMask) = self.segmentCough(x, xReal, fs, coughPadding: 0.2)
        
        print("out coughSegmentationNew")
        return (coughSegments, coughMask)
    }
    
    //  static  func segmentCough(x: [Float], xReal: [Float], fs: Float, coughPadding: Float = 0.0, minCoughLen: Float = 0.15, thLMultiplier: Float = 0.1, thHMultiplier: Float = 2) -> ([[Float]], [Bool]) {
    //
    //        var coughMask = [Bool](repeating: false, count: x.count)
    //
    //        // Define hysteresis thresholds
    //        let rms = sqrt(x.map { $0 * $0 }.reduce(0.0, +) / Float(x.count))
    //        let segThL = thLMultiplier * rms
    //        let segThH = thHMultiplier * rms
    //
    //        // Segment coughs
    //        var coughSegments: [[Float]] = []
    //        let padding = Int(fs * coughPadding)
    //        let minCoughSamples = Int(fs * minCoughLen)
    //        var coughStart = 0
    //        var coughEnd = 0
    //        var coughInProgress = false
    //        let tolerance = Int(0.01 * fs)
    //        var belowThCounter = 0
    //
    //        for (i, sample) in x.enumerated() {
    //            let sampleSquared = sample * sample
    //
    //            if coughInProgress {
    //                // Counting and adding cough samples
    //                if sampleSquared < segThL {
    //                    belowThCounter += 1
    //                    if belowThCounter > tolerance {
    //                        coughEnd = i + padding < x.count ? i + padding : x.count - 1
    //                        coughInProgress = false
    //                        if coughEnd + 1 - coughStart - 2 * padding > minCoughSamples {
    //                            let segment = Array(xReal[coughStart...coughEnd])
    //                            coughSegments.append(segment)
    //
    //                            // Set coughMask values to true for this segment
    //                            for j in coughStart...coughEnd {
    //                                coughMask[j] = true
    //                            }
    //                        }
    //                    }
    //                }
    //                // Cough end
    //                else if i == x.count - 1 {
    //                    coughEnd = i
    //                    coughInProgress = false
    //                    if coughEnd + 1 - coughStart - 2 * padding > minCoughSamples {
    //                        let segment = Array(xReal[coughStart...coughEnd])
    //                        coughSegments.append(segment)
    //
    //                        // Set coughMask values to true for this segment
    //                        for j in coughStart...coughEnd {
    //                            coughMask[j] = true
    //                        }
    //                    }
    //                }
    //                // Reset counter for the number of sample tolerance
    //                else {
    //                    belowThCounter = 0
    //                }
    //            } else {
    //                // Start cough
    //                if sampleSquared > segThH {
    //                    coughStart = i - padding >= 0 ? i - padding : 0
    //                    coughInProgress = true
    //                }
    //            }
    //        }
    //
    //        return (coughSegments, coughMask)
    //    }
    
    
    static func segmentCough(_ x: [Float], _ xReal: [Float], _ fs: Float, coughPadding: Float = 0.0, minCoughLen: Float = 0.15, thLMultiplier: Float = 0.05, thHMultiplier: Float = 1.5) -> ([[Float]], [Bool]) {
        // Initialize cough mask as an array of false values
        
        var coughMask = [Bool](repeating: false, count: x.count)
        
        // Calculate RMS energy
        let rms = sqrt(x.reduce(0.0) { $0 + ($1 * $1) } / Float(x.count))
        
        // Define hysteresis thresholds
        let segThL = thLMultiplier * rms
        let segThH = thHMultiplier * rms
        
        // Segment coughs
        var coughSegments = [[Float]]()
        let padding = Int(fs * coughPadding)
        let minCoughSamples = Int(fs * minCoughLen)
        var coughStart = 0
        var coughEnd = 0
        var coughInProgress = false
        let tolerance = Int(0.01 * fs)
        var belowThCounter = 0
        
        for (i, sample) in x.enumerated() {
            let sampleSquared = sample * sample
            
            if coughInProgress {
                // Counting and adding cough samples
                if sampleSquared < segThL {
                    belowThCounter += 1
                    if belowThCounter > tolerance {
                        coughEnd = i + padding < x.count ? i + padding : x.count - 1
                        coughInProgress = false
                        if coughEnd + 1 - coughStart - 2 * padding > minCoughSamples {
                            let coughSlice = Array(xReal[coughStart...coughEnd])
                            coughSegments.append(coughSlice)
                            
                            // Update cough mask within the range
                            for j in coughStart...coughEnd {
                                coughMask[j] = true
                            }
                        }
                    }
                }
                // Cough end
                else if i == x.count - 1 {
                    coughEnd = i
                    coughInProgress = false
                    if coughEnd + 1 - coughStart - 2 * padding > minCoughSamples {
                        let coughSlice = Array(xReal[coughStart...coughEnd])
                        coughSegments.append(coughSlice)
                        
                        // Update cough mask within the range
                        for j in coughStart...coughEnd {
                            coughMask[j] = true
                        }
                    }
                }
                // Reset counter for number of sample tolerance
                else {
                    belowThCounter = 0
                }
            } else {
                // Start cough
                if sampleSquared > segThH {
                    coughStart = i - padding >= 0 ? i - padding : 0
                    coughInProgress = true
                }
            }
        }
        
        return (coughSegments, coughMask)
    }
    
    static func instance(array: [Float], fs: Float, rsp: Float,buffer: AVAudioPCMBuffer) -> ([String], Int, [[Float]]?,String) {
        var segmentProbs: [Float] = []
        var segmentPowers: [String] = []
        var segments: [[Float]]?
        var power: String = ""
        
        // Call cough_event_inference and other functions as needed
        let (pred, probs) = coughEventInference(array)
        
        if pred == 1 {
            
            // Call cough_segment_inference and process the segments
            (segments, segmentProbs) = PythonFunctions.coughSegmentInference(audioData: array, fs: fs, buffer: buffer)
            
            
            if let segments = segments {
                
                // Calculate power for each segment
                for wave in segments {
                    let soundPower = PythonFunctions.powerByAVFoundation(wave,fs,buffer: buffer)
                    power = PythonFunctions.calculateAdaptiveLoudness(loudness: soundPower, rspLoudness: rsp)
                    print("Total Power",power)
                    segmentPowers.append(power)
                }
                return (segmentPowers, segments.count, segments,power)
            } else {
                print("No segments or No cough segments...")
                return ([], 0, nil,"")
            }
        } else {
            print("Cough Not Found...")
            return ([], 0, nil,"")
        }
    }
    
    
    
    
    static func coughEventInference(_ input: [Float]) -> (Int, Float) {
        let x = PythonFunctions.padding(audioData: input)
        
        
        
        var cough = 0
        var coughData:Float = 0.0
        
        if let modelPath = Bundle.main.path(forResource: "final_model_weights_no_optimization_v3", ofType: "tflite") {
            
            guard let interpreter = try? Interpreter(modelPath: modelPath) else {
                fatalError("Error initializing interpreter")
            }
            
            
            try! interpreter.allocateTensors()
            
            
            //                        let inputDetails = try! interpreter.input(at: 0)
            //                        let outputDetails = try! interpreter.output(at: 0)
            
            
            let data = Data(buffer: UnsafeBufferPointer(start: x, count: x.count))
            
            try! interpreter.copy(data, toInputAt: 0)
            
            // Invoke the model
            try? interpreter.invoke()
            
            
            guard let outputTensor = try? interpreter.output(at: 0) else {
                fatalError("Error getting output data")
            }
            
            let outputSize = outputTensor.shape.dimensions.reduce(1, {x, y in x * y})
            
            let outputData = UnsafeMutableBufferPointer<Float32>.allocate(capacity: outputSize)
            outputTensor.data.copyBytes(to: outputData)
            
            //            let outputData = outputTensor.data.copyBytes(to: out)
            
            coughData = Float(outputData[0])
            
            
            //            cough = outputData[0] >= UInt8(0.80) ? (1, Float(outputData[0])) : (0, Float(outputData[0]))
            
            cough = coughData >= 0.80 ? 1 : 0
        }else{
            
            print("Cough not found")
            
        }
        
        
        return (cough,coughData)
    }
    
    static func padding(audioData: [Float]) -> [Float] {
        let desiredLength = 44288
        var audioData = Array(audioData.prefix(44100))
        
        if audioData.count < desiredLength {
            let paddingCount = desiredLength - audioData.count
            audioData.append(contentsOf: [Float](repeating: 0.0, count: paddingCount))
        }
        
        return audioData
    }
    
    static func saveWAVFileToDocumentsDirectory(floatArray: [Float], sampleRate: Double, fileName: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try convertFloatAudioToWAV(floatArray: floatArray, sampleRate: sampleRate, filePath: filePath)
            return filePath
        } catch {
            throw error
        }
    }
    
    
    static func convertFloatAudioToWAV(floatArray: [Float], sampleRate: Double, filePath: URL) throws {
        
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
        
        let audioFile = try AVAudioFile(forWriting: filePath, settings: audioFormat!.settings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: AVAudioFrameCount(floatArray.count))
        buffer!.frameLength = AVAudioFrameCount(floatArray.count)
        
        for i in 0..<Int(buffer!.frameLength) {
            buffer!.floatChannelData![0][i] = floatArray[i]
        }
        
        try audioFile.write(from: buffer!)
    }
}
