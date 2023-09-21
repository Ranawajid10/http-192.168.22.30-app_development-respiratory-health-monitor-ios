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
    
    @Published var isError = false
    @Published var errorMessage:String = ""
    
    
    @Published var isSyncing = false
    @Published var isDeleteAllCough = false
    
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
    
    @Published var allCoughList:[VolunteerCough] = []
    
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
        
        
        let audioEngine = AVAudioEngine()
         let audioInputNode = audioEngine.inputNode

         // Add an equalization filter to reduce background noise
         let eqFilter = AVAudioUnitEQ(numberOfBands: 1)
         eqFilter.globalGain = -20 // Adjust this value to reduce noise

         audioEngine.attach(eqFilter)
         audioEngine.connect(audioInputNode, to: eqFilter, format: audioInputNode.outputFormat(forBus: 0))
         audioEngine.connect(eqFilter, to: audioEngine.mainMixerNode, format: audioInputNode.outputFormat(forBus: 0))
        
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
                
                let cc =  PythonFunctions.instance(array: x, fs: fs, rsp: rsp,buffer: buffer!)
                
                
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
    
    
    func decideCoughUpload(){
        
        if(MyUserDefaults.getBool(forKey: Constants.isFirstSync)){
            
            uploadAllCoughs()
            
        }else{
            
            print("upload first five",allCoughList.count)
            uploaFirstFiveCoughs()
            
        }
        
        
    }
    
    func uploadAllCoughs(){
        
        isSyncing = true
        
        ApiClient.shared.uploadSamples(allCoughList: allCoughList) { [self] response in
            
            isSyncing = false
            
            switch response {
            case .success(_):
                
                MyUserDefaults.saveBool(forKey: Constants.isFirstSync, value: false)
                isDeleteAllCough = true
                
                break
            case .failure(_):
                isDeleteAllCough = false
                break
            }
        }
        
        
    }
    
    
    func uploaFirstFiveCoughs(){
        
        isSyncing = true
        
        ApiClient.shared.uploadSamples(allCoughList: allCoughList) { [self] response in
            
            isSyncing = false
            
            switch response {
            case .success(_):
                
                isDeleteAllCough = true
                
                break
            case .failure(_):
                isDeleteAllCough = false
                break
            }
        }
        
        
    }
    
    
    
    
    
    
   
    
    // Usage example
    //    let inputData = [Float](repeating: 0.0, count: 100) // Replace with your actual input data
    //    let (pred, probs) = coughEventInference(inputData)
    //    print("Prediction: \(pred), Probability: \(probs)")
    
    
}
