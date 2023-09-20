//
//  DashboardVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 12/09/2023.
//

import Foundation
import AVFoundation
import TensorFlowLite


class DashboardVM:ObservableObject{
    
    @Published var saveCough = false
    @Published  var isRecording = false
    @Published private var isPlaying = false
    @Published private var audioRecorder: AVAudioRecorder!
    @Published private var audioFileURL: URL?
    
    @Published var audioPlayer : AVAudioPlayer!
    
    @Published var recordingsList = [URL]()
    
    @Published var segments:[[Float]] = []
    @Published var coughPower:String = ""
    
    var counter = 0
    
    private var recordingStartTime: Date?
    
    @Published var totalSecondsRecordedToday: Double = 0.0
    
    
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
            
            recordingStartTime = Date()
            
            
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
        
        if isRecording {
            
            audioRecorder.stop()
           
            
            // Calculate the duration in hours
            if let recordingStartTime = recordingStartTime {
                let recordingEndTime = Date()
                let durationInSeconds = recordingEndTime.timeIntervalSince(recordingStartTime)
//                let durationInHours = durationInSeconds / 3600.0 // 3600 seconds in an hour
                
                // Increment the total hours recorded today
                totalSecondsRecordedToday = durationInSeconds
                
            }
            
            
            if let audioFileURL = audioFileURL {
                // Delete the audio file
                if FileManager.default.fileExists(atPath: audioFileURL.path) {
                    do {
                        try FileManager.default.removeItem(at: audioFileURL)
                    } catch {
                        print("Error deleting audio file: \(error.localizedDescription)")
                    }
                }
            }
            
            isRecording = false
            
            
        }
    }
    
    func recordChunk() {
        guard isRecording else {
            return
        }
        
        audioRecorder?.stop()
        
        do{
            
            let data = try? Data(contentsOf: audioFileURL!)
            if let audioData = data {
                
                // Here you can convert the audioData to a byte array as needed
                
                let audioFile = try AVAudioFile(forReading: audioFileURL!)
                
                let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false)
                let frameCount = UInt32(audioFile.length)
                let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: frameCount)
                try! audioFile.read(into: buffer!)
                
                let x = Array(UnsafeBufferPointer(start: buffer!.floatChannelData?[0], count: Int(frameCount)))
                let fs = Float(audioFile.fileFormat.sampleRate)
                
                //                try saveWAVFileToDocumentsDirectory(floatArray: x, sampleRate: 22050, fileName: "my_new"+String(counter)+".wav")
                //
                //                counter+=1
                
                
                //                (segments, _) = PythonFunctions.coughSegmentInference(audioData: x, fs: fs ,buffer:buffer!)
                
                //                for s in segments {
                //
                //                    try saveWAVFileToDocumentsDirectory(floatArray: s, sampleRate: 22050, fileName: "my_new"+String(counter)+".wav")
                //                    counter+=1
                //                }
                
                let rsp = MyUserDefaults.getFloat(forKey: Constants.baseLineLoudness)
                
                let cc =  instance(array: x, fs: fs, rsp: rsp,buffer: buffer!)
                
                print("Da",cc.2?.count ?? 0,"\n\n\n\n\n")
                
                if(cc.2?.count ?? 0>0){
                    
                    DispatchQueue.main.async { [self] in
                        segments = cc.2 ?? []
                        coughPower = cc.3
                        saveCough = true
                    }
                    
                    
                }
                
                // Restart recording after recording a chunk
                audioRecorder?.record()
            }
            
        }catch{
            
            print("Error reading audio file: \(error.localizedDescription)")
            
        }
    }
    
    
    func saveWAVFileToDocumentsDirectory(floatArray: [Float], sampleRate: Double, fileName: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try convertFloatAudioToWAV(floatArray: floatArray, sampleRate: sampleRate, filePath: filePath)
            return filePath
        } catch {
            throw error
        }
    }
    
    
    func convertFloatAudioToWAV(floatArray: [Float], sampleRate: Double, filePath: URL) throws {
        
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
        
        let audioFile = try AVAudioFile(forWriting: filePath, settings: audioFormat!.settings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: AVAudioFrameCount(floatArray.count))
        buffer!.frameLength = AVAudioFrameCount(floatArray.count)
        
        for i in 0..<Int(buffer!.frameLength) {
            buffer!.floatChannelData![0][i] = floatArray[i]
        }
        
        try audioFile.write(from: buffer!)
    }
    
    func instance(array: [Float], fs: Float, rsp: Float,buffer: AVAudioPCMBuffer) -> ([String], Int, [[Float]]?,String) {
        var segmentProbs: [Float] = []
        var segmentPowers: [String] = []
        var segments: [[Float]]?
        var power: String = ""
        
        // Call cough_event_inference and other functions as needed
        let (pred, probs) = coughEventInference(array)
        print("prediction ",pred)
        
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
    
    
    
    
    func coughEventInference(_ input: [Float]) -> (Int, Float) {
        let x = padding(audioData: input)
        
        print("x----------",x.count)
        
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
            
            print("cough data",coughData)
            
            //            cough = outputData[0] >= UInt8(0.80) ? (1, Float(outputData[0])) : (0, Float(outputData[0]))
            
            cough = coughData >= 0.80 ? 1 : 0
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
