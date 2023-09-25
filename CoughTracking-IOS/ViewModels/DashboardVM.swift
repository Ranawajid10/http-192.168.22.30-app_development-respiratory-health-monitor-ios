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
    
    @Published var saveHours = false
    @Published var saveCough = false
    @Published  var isRecording = false
    @Published private var audioRecorder: AVAudioRecorder!
    @Published private var audioFileURL: URL?
    
    @Published var audioPlayer : AVAudioPlayer!
    
    @Published var recordingsList = [URL]()
    
    @Published var segments:[[Float]] = []
    @Published var coughPower:String = ""
    
    var counter = 0
    
    private var recordingStartTime: Date?
    
    @Published var totalSecondsRecordedToday: Double = 0.0
    
    @Published var valunteerCoughList:[VolunteerCough] = []
    @Published var coughTrackHourList:[CoughTrackingHours] = []
    
    
    // Play Audio
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    
    @Published var playbackProgress: Double = 0.0 // Publish playback progress
    @Published var isPlaying: Bool = false
    private var audioPlaytimer: Timer?
    
    
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
            saveTrackedHours()
            
        }
    }
    
    func saveTrackedHours(){
        
        DispatchQueue.main.async { [self] in
            
            // Calculate the duration in hours
            if let recordingStartTime = recordingStartTime {
                let recordingEndTime = Date()
                let durationInSeconds = recordingEndTime.timeIntervalSince(recordingStartTime)
                //                let durationInHours = durationInSeconds / 3600.0 // 3600 seconds in an hour
                
                // Increment the total hours recorded today
                totalSecondsRecordedToday = durationInSeconds
                Constants.totalSecondsRecordedToday = totalSecondsRecordedToday
                
                
            }
            
            
            saveHours = true
            
        }
        
        
        
    }
    
    
    func recordChunk() {
        guard isRecording else {
            return
        }
        
        audioRecorder?.stop()
        
        do{
            
            let data = try? Data(contentsOf: audioFileURL!)
            if data != nil {
                
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
                
//                saveTrackedHours()
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
            
            print("upload first five",valunteerCoughList.count)
            uploaFirstFiveCoughs()
            
        }
        
        
    }
    
    func uploadAllCoughs(){
        
        isSyncing = true
        
        ApiClient.shared.uploadSamples(allCoughList: valunteerCoughList) { [self] response in
            
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
        
        ApiClient.shared.uploadSamples(allCoughList: valunteerCoughList) { [self] response in
            
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
    
    func playSample(floatArray:[[Float]]){
        
        stopRecording()
        
        if(isRecording){
           
            stopRecording()
            
        }
        
        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: 0)
        
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
        
        if let audioBuffer = Functions.convertToAudioBuffer(floatArray: floatArray, sampleRate: 22050) {
            
           playAudio(buffer: audioBuffer)
            
        }
        
        
        
        
    }
    
    func playAudio(buffer: AVAudioPCMBuffer) {
        do {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
            
            player.scheduleBuffer(buffer, completionHandler: nil)
            
            try engine.start()
            
            // Start the audio player
            player.play()
            
            // Create a timer to update playbackProgress in real-time
            audioPlaytimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.player.isPlaying {
                    if let lastRenderTime = self.player.lastRenderTime,
                       let playerTime = self.player.playerTime(forNodeTime: lastRenderTime) {
                        // Calculate the current playback progress within the range [0, 1]
                        let currentTime = Double(playerTime.sampleTime) / Double(playerTime.sampleRate)
                        let totalDuration = Double(buffer.frameLength) / buffer.format.sampleRate
                        //                        let progress = min(1.0, max(0.0, currentTime / totalDuration))
                        let progress = currentTime / totalDuration
                        
                        self.playbackProgress = progress
                        
                        self.isPlaying = true
                        
                        // Post the progress notification only if not completed
                        
                        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: progress)
                        
                        
                        if progress > 1.0 {
                            
                            self.isPlaying = false
                            self.audioPlaytimer?.invalidate()
                            
                            startRecording()
                            
                        }
                    }
                } else {
                    // Audio playback has finished, invalidate the timer
                    self.isPlaying = false
                    self.audioPlaytimer?.invalidate()
                    
                    startRecording()
                }
            }
        } catch {
            self.isPlaying = false
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func pauseAudio() {
        player.pause()
    }
    
    
    
    
    // Usage example
    //    let inputData = [Float](repeating: 0.0, count: 100) // Replace with your actual input data
    //    let (pred, probs) = coughEventInference(inputData)
    //    print("Prediction: \(pred), Probability: \(probs)")
    
    
}
