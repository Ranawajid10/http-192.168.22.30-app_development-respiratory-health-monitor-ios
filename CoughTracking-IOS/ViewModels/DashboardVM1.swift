//
//  DashboardVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 08/09/2023.
//

import Foundation
import AVFoundation
import TensorFlowLite


class DashboardVM1:ObservableObject{
    
    @Published private var isRecording = false
    @Published private var isPlaying = false
    @Published private var audioRecorder: AVAudioRecorder!
    @Published private var audioFileURL: URL?
    
    @Published var audioPlayer : AVAudioPlayer!
    
    @Published var recordingsList = [URL]()
    
    @Published var segments:[[Float]] = []
    
    func startRecording(){
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("CO-Voice : \(Date()).m4a")
        
        audioFileURL = fileName
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
        } catch {
            print("Failed to Setup the Recording")
        }
        
        DispatchQueue.global().async {
            while self.isRecording {
                self.recordChunk()
                Thread.sleep(forTimeInterval: 2)
            }
        }
        
    }
    
    
    func stopRecording(){
        audioRecorder.stop()
        isRecording = false
    }
    
    func recordChunk() {
        guard isRecording else {
            return
        }
        
        audioRecorder?.stop()
        
        do{
            
            let data = try? Data(contentsOf: audioFileURL!)
            if let audioData = data {
                print("Recording chunk with \(audioData.count) bytes")
                // Here you can convert the audioData to a byte array as needed
                
                let audioFile = try AVAudioFile(forReading: audioFileURL!)
                
                let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false)
                let frameCount = UInt32(audioFile.length)
                let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: frameCount)
                try! audioFile.read(into: buffer!)
                
                let x = Array(UnsafeBufferPointer(start: buffer!.floatChannelData?[0], count: Int(frameCount)))
                let fs = Float(audioFile.fileFormat.sampleRate)
                
                //                (segments, _) = PythonFunctions.coughSegmentInference(audioData: x, fs: fs ,buffer:buffer!)
                let cc =  instance(array: x, fs: fs, rsp: -16.511724,buffer: buffer!)
                
                print("Da",cc.0,"\n\n\n\n\n")
                // Restart recording after recording a chunk
                audioRecorder?.record()
            }
            
        }catch{
            
            print("Error reading audio file: \(error.localizedDescription)")
            
        }
    }
    
    func instance(array: [Float], fs: Float, rsp: Float,buffer: AVAudioPCMBuffer) -> ([String], Int, [[Float]]?) {
        var segmentProbs: [Float] = []
        var segmentPowers: [String] = []
        var segments: [[Float]]?
        
        // Call cough_event_inference and other functions as needed
        let (pred, probs) = coughEventInference(array)
        //        print("baseline loudness", rsp)
        print("predinction ",pred)
        
        if pred == 1 {
            //            print("[::][::][::]Model 1 : Cough found... [::][::][::]", probs)
            
            // Call cough_segment_inference and process the segments
            (segments, segmentProbs) = PythonFunctions.coughSegmentInference(audioData: array, fs: fs, buffer: buffer)
            
            //            print("[::][::][::]Model 2 : Cough segments found \(segments?.count ?? 0) ...", segmentPowers)
            
            if let segments = segments {
                
                // Calculate power for each segment
                for wave in segments {
                    let soundPower = PythonFunctions.powerByAVFoundation(wave,fs,buffer: buffer)
                    let power = PythonFunctions.calculateAdaptiveLoudness(loudness: soundPower, rspLoudness: rsp)
                    print("sasa",power)
                    //                    print("[::][::][::]Baseline power:", rsp, "Sound power:", soundPower, "sound intensity level:", power)
                    //                                        segmentPowers.append(power)
                }
                return (segmentPowers, segments.count, segments)
            } else {
                print("No segments or No cough segments...")
                return ([], 0, nil)
            }
        } else {
            print("Cough Not Found...")
            return ([], 0, nil)
        }
    }
    
    
    
    
    func coughEventInference(_ input: [Float]) -> (Int, Float) {
        let x = padding(audioData: input)
        
        print("x",x.count)
        
        var cough = 0
        var coughData:Float = 0.0
        
        if let modelPath = Bundle.main.path(forResource: "final_model_weights_no_optimization_v3", ofType: "tflite") {
            
            guard let interpreter = try? Interpreter(modelPath: modelPath) else {
                fatalError("Error initializing interpreter")
            }
            
            
            try! interpreter.allocateTensors()
            
            
//            let inputDetails = try! interpreter.input(at: 0)
//            let outputDetails = try! interpreter.output(at: 0)
            
            
            let data = Data(buffer: UnsafeBufferPointer(start: x, count: x.count))
            
            try? interpreter.copy(data, toInputAt: 0)
            
            // Invoke the model
            try? interpreter.invoke()
            
            
            guard let outputTensor = try? interpreter.output(at: 0) else {
                fatalError("Error getting output data")
            }
            
            let outputData = outputTensor.data
            
            coughData = Float(outputData[0])
            
            print("cough data",coughData)
            
            //            cough = outputData[0] >= UInt8(0.80) ? (1, Float(outputData[0])) : (0, Float(outputData[0]))
            
            cough = UInt8(coughData) >= UInt8(0.80) ? 1 : 0
        }else{
            
            print("not found")
            
        }
        
        
        return (cough,coughData)
    }
    
    func padding(audioData: [Float]) -> [Float] {
        let desiredLength = 44288
        var audioData = Array(audioData.prefix(44100))
        
        if audioData.count < desiredLength {
            let paddingCount = desiredLength - audioData.count
            audioData.append(contentsOf: [Float](repeating: 0.0, count: paddingCount))
        }
        
        return audioData
    }
    
    // Usage example
    //    let inputData = [Float](repeating: 0.0, count: 100) // Replace with your actual input data
    //    let (pred, probs) = coughEventInference(inputData)
    //    print("Prediction: \(pred), Probability: \(probs)")
    
    
}
