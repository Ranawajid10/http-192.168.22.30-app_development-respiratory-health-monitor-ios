//
//  DashboardVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 12/09/2023.
//

import Foundation
import AVFoundation
import TensorFlowLite
import SwiftAudioPlayer


class DashboardVM:ObservableObject{
    
    @Published var isUploaded = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage:String = ""
    @Published var showScheduleSheet = false
    @Published var isScheduled = false
    @Published var terminateApp = false
    
    @Published var isSyncing = false
    @Published var isDeleteAllCough = false
    
    @Published var remoteURLStatus = 0
    
    @Published var saveHours = false
    @Published var saveCough = false
    @Published  var isRecording = false
    @Published private var audioRecorder: AVAudioRecorder!
    @Published private var audioFileURL: URL?
    
    @Published var audioPlayer : AVAudioPlayer!
    
    @Published var recordingsList = [URL]()
    
    @Published var segments:[(key: [[Float]], value: String)] = []
    @Published var coughPower:String = ""
    
    @Published var trackedSecondsByHour: [TrackedMinutes] = []
    
    var counter = 0
    
    private var recordingStartTime: Date?
    
    @Published var totalSecondsRecordedToday: Double = 0.0
    
    @Published var valunteerCoughList:[VolunteerCough] = []
    @Published var coughTrackHourList:[TrackedHours] = []
    @Published var uploadTrackingHoursList: [HoursUpload] = []
    @Published var uploadNotesList: [UploadNotes] = []
    
    @Published var userData = LoginResult()
    
    
    // Play Audio
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    
    @Published var playbackProgress: Double = 0.0 // Publish playback progress
    @Published var isPlaying: Bool = false
    private var audioPlaytimer: Timer?
    
    
    
    //Schedule Monitoring
    
    @Published var fromSelectedHour = 0
    @Published var fromSelectedMin = 0
    @Published var fromSelectedAM = 0
    
    
    @Published var toSelectedHour = 0
    @Published var toSelectedMin = 0
    @Published var toSelectedAM = 0
    
    var recordingThread: Thread?
    
    //    let coughDetector = CoughDetector()
    
    //    init(){
    //
    //        coughDetector.coughDetectionHandler = { [self] recordedSegments ,power in
    //
    //            if(recordedSegments.count>0){
    //
    //                DispatchQueue.main.async { [self] in
    //                    segments = recordedSegments
    //                    coughPower = power
    //                    saveCough = true
    //                }
    //
    //
    //                print("coughDetector","yes")
    //
    //            }else{
    //
    ////                print("coughDetector","no")
    //
    //            }
    //
    //        }
    //
    //    }
    
    
    //        coughDetector.startRecording()
    //        return
    //        coughDetector.stopRecording()
    //
    //        return
    //
    
    func startRecording(){
        
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("CO-Voice : \(DateUtills.getCurrentTimeInMilliseconds()).m4a")
        
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
            
            segments.removeAll()
            
            
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
            recordingStartTime = Date()
            
            recordingThread = Thread {
                while self.isRecording {
                    self.recordChunk()
                    Thread.sleep(forTimeInterval: 2)
                }
            }
            
            recordingThread?.start()
            
        } catch {
            print("Failed to Setup the Recording")
        }
        
        
        
    }
    
    func recordChunk() {
        guard isRecording else {
            return
        }
        
        audioRecorder?.stop()
        
        
        do{
            
            // Here you can convert the audioData to a byte array as needed
            
            let audioFile = try AVAudioFile(forReading: audioFileURL!)
            let frameCount = UInt32(audioFile.length)
            let format = audioFile.processingFormat
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
            
            if let buffer = buffer {
                try! audioFile.read(into: buffer)
                
                let x = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(frameCount)))
                let fs = Float(audioFile.fileFormat.sampleRate)
                
                
                let rsp = MyUserDefaults.getFloat(forKey: Constants.baseLineLoudness)
                
                let cc =  PythonFunctions.instance(array: x, fs: fs, rsp: rsp,buffer: buffer)
                
                
                if(cc.2?.count ?? 0>0){
                    
                    DispatchQueue.main.async { [self] in
                        segments.append((cc.2 ?? [],cc.3))
                        coughPower = cc.3
                        saveCough = true
                    }
                    
                    
                }
                
                DispatchQueue.main.async { [self] in
                    
                    // Calculate the duration in hours
                    if let recordingStartTime = recordingStartTime {
                        let recordingEndTime = Date()
                        let durationInSeconds = recordingEndTime.timeIntervalSince(recordingStartTime)
                        //                let durationInHours = durationInSeconds / 3600.0 // 3600 seconds in an hour
                        
                        // Increment the total hours recorded today
                        totalSecondsRecordedToday = durationInSeconds
                        Constants.totalSecondsRecordedToday = totalSecondsRecordedToday
                        
                        if(DateUtills.isHourComplete(date: Date()) && !MyUserDefaults.getBool(forKey: Constants.isUploadedInThisHour)){
                            
                            MyUserDefaults.saveBool(forKey: Constants.isUploadedInThisHour, value: false)
                            saveHours = true
                            
                        }
                        
                        
                    }
                    
                    if let scheduleToDate = MyUserDefaults.getDate(forKey: Constants.scheduledToDate){
                        
                        if DateUtills.changeDateFormat(date: scheduleToDate, newFormat: DateTimeFormats.dateTimeFormat4) != nil{
                            
                            
                            if Date() >= scheduleToDate {
                                
                                MyUserDefaults.removeDate(key: Constants.scheduledToDate)
                                MyUserDefaults.saveString(forKey: "closee", value: "yes"+DateUtills.getCurrentDateInString(format: DateTimeFormats.dateTimeFormat4))
                                
                                exit(-1)
                                
                                //                            terminateApp = true
                                
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            
        }catch{
            
            print("Error reading audio file: \(error.localizedDescription)")
            
        }
        
        // Restart recording after recording a chunk
        audioRecorder?.record()
        
        
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
            
            recordingThread?.cancel()
            recordingThread = nil
            
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
    
    
    
    
    //    func decideCoughUpload(){
    //
    //        if(MyUserDefaults.getBool(forKey: Constants.isFirstSync)){
    //
    //            uploadAllCoughs()
    //
    //        }else{
    //
    //            print("upload first five",valunteerCoughList.count)
    //            uploaFirstFiveCoughs()
    //
    //        }
    //
    //
    //    }
    //
    //    func uploadAllCoughs(){
    //
    //        isSyncing = true
    //
    //        ApiClient.shared.uploadSamples(allCoughList: valunteerCoughList) { [self] response in
    //
    //            isSyncing = false
    //
    //            switch response {
    //            case .success(_):
    //
    //                MyUserDefaults.saveBool(forKey: Constants.isFirstSync, value: false)
    //                isDeleteAllCough = true
    //
    //                break
    //            case .failure(_):
    //                isDeleteAllCough = false
    //                break
    //            }
    //        }
    //
    //
    //    }
    //
    //    func uploaFirstFiveCoughs(){
    //
    //        isSyncing = true
    //
    //
    //
    //        ApiClient.shared.uploadSamples(allCoughList: valunteerCoughList) { [self] response in
    //
    //            isSyncing = false
    //
    //            switch response {
    //            case .success(_):
    //
    //                isDeleteAllCough = true
    //
    //                break
    //            case .failure(_):
    //                isDeleteAllCough = false
    //                break
    //            }
    //        }
    //
    //
    //    }
    //
    
    func calculateTrackedMinutes(){
        
        
        
        if(!isLoading && Connectivity.isConnectedToInternet){
            
            isLoading = true
            
            
            trackedSecondsByHour.removeAll()
            
            for record in uploadTrackingHoursList {
                let components = record.dateTime?.components(separatedBy: "-") ?? []
                if components.count >= 4 {
                    
                    let dateTime = (record.dateTime?.dropLast(5) ?? "")+"00:00"
                    
                    
                    
                    if let index = trackedSecondsByHour.firstIndex(where: { $0.date == dateTime }) {
                        trackedSecondsByHour[index].minutes += record.trackedSeconds/60.0
                    } else {
                        
                        let date = DateUtills.changeDateFormat(date: String(dateTime), oldFormat: DateTimeFormats.dateTimeFormat1, newFormat: DateTimeFormats.dateFormat1)
                        let time = DateUtills.changeDateFormat(date: String(dateTime), oldFormat: DateTimeFormats.dateTimeFormat1, newFormat: DateTimeFormats.timeFormat1)
                        
                        let finalDate = date+"T"+time
                        
                        trackedSecondsByHour.append(TrackedMinutes(date: finalDate, minutes: record.trackedSeconds/60.0))
                    }
                    
                }
            }
            
            
            uploadAllCoughs()
            
        }
        
    }
    
    func uploadAllCoughs(){
        
        
        do {
            // Create a JSONEncoder to encode the data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the data to JSON data
            let jsonData = try encoder.encode(trackedSecondsByHour)
            
            // Convert the JSON data to a JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                ApiClient.shared.newUploadCoughSamplesStats(allCoughList: valunteerCoughList,stats: jsonString,token: userData.token ?? "") { [self] response in
                    
                    isLoading = false
                    
                    switch response {
                    case .success(let success):
                        print("dashboardVM result",success)
                        isUploaded = true
                        break
                    case .failure(let failure):
                        isUploaded = false
                        errorMessage = failure.localizedDescription
                        isError = true
                        break
                    }
                    
                }
                
            } else {
                isError = true
                errorMessage = "Failed to convert data to string"
                print("Failed to convert data to string")
            }
        } catch {
            isError = true
            errorMessage = "Error: \(error)"
            print("Error: \(error)")
        }
        
        
        
    }
    
    func uploadAllNotes(){
        
        ApiClient.shared.uploadNotes(allNotesList: uploadNotesList, token: userData.token ?? "") { response in
            print("res",response)
        }
        
    }
    
    
    func playSample(floatArray:[[Float]]){
        
        
        stopRecording()
        
        if(isRecording){
            
            stopRecording()
            
        }
        
//        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: 0)
        
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
        
        if let audioBuffer = Functions.convertToAudioBuffer(floatArray: floatArray, sampleRate: 22050) {
            
            DispatchQueue.main.async {
                self.playAudio(buffer: audioBuffer)
            }
            
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
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: progress)
                        }
                        
                        
                        
                        if progress > 1.0 {
                               
                            self.isPlaying = false
                            self.audioPlaytimer?.invalidate()
                            
                            self.engine.reset()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.40){
                             
                                NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: 0)
                                self.startRecording()
                            }
                          
                        }
                    }
                } else {
                    // Audio playback has finished, invalidate the timer
                    
                    self.isPlaying = false
                    self.audioPlaytimer?.invalidate()
                    
                    self.engine.reset()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.40){ [self] in
                     
                        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: 0)
                        self.startRecording()
                        
                    }
                   
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
    
    
    
    func scheduleNotification() {
        
        let calendar = Calendar.current
        
        var fromHour = ""
        var fromMin = 0
        
        var toHour = ""
        var toMin = 0
        
        
        let fromAmPm = fromSelectedAM == 0 ? "AM" : "PM"
        
        let toAmPm = toSelectedAM == 0 ? "AM" : "PM"
        
        
        fromHour = DateUtills.changeDateFormat(date: String(fromSelectedHour+1) + " " + fromAmPm , oldFormat: DateTimeFormats.timeFormat4, newFormat: DateTimeFormats.timeFormat2)
        toHour = DateUtills.changeDateFormat(date: String(toSelectedHour+1) + " " + toAmPm, oldFormat: DateTimeFormats.timeFormat4, newFormat: DateTimeFormats.timeFormat2)
        
        
        
        fromMin = fromSelectedMin
        
        fromMin+=1
        
        
        toMin = toSelectedMin
        
        toMin+=1
        
        
        guard let currentDateTime = DateUtills.changeDateFormat(date: Date(), newFormat: DateTimeFormats.dateTimeFormat3) else { return }
        
        
        let dateFrom = DateUtills.getCurrentDateInString(format: DateTimeFormats.dateFormat1)
        let timeFrom = String(fromHour) + ":" + String(fromMin) + ":00"
        
        let dateTimeFrom = dateFrom+"-"+timeFrom
        
        let finalFromDate = DateUtills.stringToDate(date: dateTimeFrom, dateFormat: DateTimeFormats.dateTimeFormat3)
        
        
        
        let dateTo = DateUtills.getCurrentDateInString(format: DateTimeFormats.dateFormat1)
        let timeTo = String(toHour) + ":" + String(toMin) + ":00"
        
        let dateTimeTo = dateTo+"-"+timeTo
        
        let finalToDate = DateUtills.stringToDate(date: dateTimeTo, dateFormat: DateTimeFormats.dateTimeFormat3)
        
        if(finalFromDate == finalToDate){
            
            errorMessage = "Both time can not be same"
            isError = true
            return
        }
        
        if(finalFromDate > finalToDate){
            
            errorMessage = "Schedule from time can not greater than Schedule to time"
            isError = true
            return
        }
        
        
        if(finalFromDate < currentDateTime){
            
            errorMessage = "Schedule from time can not less than Schedule to time"
            isError = true
            return
            
        }
        
        
        let dFrom = DateUtills.changeDateFormat(date: finalFromDate, oldFormat: DateTimeFormats.dateTimeFormat3, newFormat: DateTimeFormats.dateTimeFormat4)
        let triggerFromDate = DateUtills.stringToDate(date: dFrom, dateFormat: DateTimeFormats.dateTimeFormat4)
        
        
        
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerFromDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        
        let content = UNMutableNotificationContent()
        content.title = "Schedule Cough Monitor"
        content.body = "Click to start Scheduled Cough Monitoring"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "com.ai4lyf.CoughTracking.IOS", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [self] error in
            if let error = error {
                
                DispatchQueue.main.async { [self] in
                    errorMessage = error.localizedDescription
                    isError = true
                }
                
            }else{
                
                DispatchQueue.main.async {  [self] in
                    
                    MyUserDefaults.saveDate(forKey: Constants.scheduledToDate, value: finalToDate)
                    isScheduled = true
                    showScheduleSheet.toggle()
                    
                    print("saved")
                    
                }
                
                
            }
        }
    }
    
    
    func playAudio(remoteURL: String) {
        
        stopRecording()
        
        if(isRecording){
            
            stopRecording()
            
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
        
        print("yes",remoteURL)
        
        engine.stop()
        
        
        let url = URL(string: remoteURL)!
        SAPlayer.shared.startRemoteAudio(withRemoteUrl: url)
        SAPlayer.shared.play()
        
        
        //        _ = SAPlayer.Updates.StreamingBuffer.subscribe{ [weak self] buffer in
        //                guard let self = self else { return }
        //
        //               print(buffer)
        //
        ////                self.isPlayable = buffer.isReadyForPlaying
        //            }
        //
        _ = SAPlayer.Updates.PlayingStatus.subscribe({ [self] playingStatus in
            
            if(playingStatus == SAPlayingStatus.buffering){
                
                remoteURLStatus = 1 // loading
                
            }else if(playingStatus == SAPlayingStatus.playing){
                
                remoteURLStatus = 2 // playing
                
                
            }else if(playingStatus == SAPlayingStatus.paused){
                
                remoteURLStatus = 3 // paused
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1){ [self] in
                    
                    startRecording()
                    
                }
                
            }else if(playingStatus == SAPlayingStatus.ended){
                
                remoteURLStatus = 0 // ended
                
                
            }
            print("playingStatus",playingStatus)
            
        })
        
        
        // Create a Timer that fires every 1 second
        //        let timer = Timer.scheduledTimer(withTimeInterval: 0.30, repeats: true) { timer in
        //
        //
        //
        //
        //            if((SAPlayer.shared.playerNode?.isPlaying) != nil){
        //
        //                print("playing")
        //
        //            }else{
        //
        //
        //                timer.invalidate()
        //
        //            }
        //
        //        }
        
        // To stop the timer when you're done, you can invalidate it
        // timer.invalidate()
        
        // This will start the timer and it will print the message every second until invalidated.
        //        RunLoop.current.run()
        
        
        
        
        
        
        
    }
    
    // Usage example
    //    let inputData = [Float](repeating: 0.0, count: 100) // Replace with your actual input data
    //    let (pred, probs) = coughEventInference(inputData)
    //    print("Prediction: \(pred), Probability: \(probs)")
    
    
}


//class AudioPlayerManager {
//    static let shared = AudioPlayerManager()
//     let skAudioPlayer: SAPlayer
//
//    init() {
//
//    }
//
//    func playAudio(withUrl url: String) {
//
//
//
//        print("yes",url)
//
//        let url = URL(string: withUrl)!
//        skAudioPlayer.startRemoteAudio(withRemoteUrl: <#T##URL#>)
//
//
//    }
//    func pauseAudio() {
//        audioPlayer.pause()
//    }
//    func stopAudio() {
//        audioPlayer.stop()
//    }
//    func playAudio() {
//        audioPlayer.play()
//    }
//    func seekAudio(seconds: TimeInterval) {
//        audioPlayer.seek(to: seconds)
//    }
//    func seekForward(seconds: TimeInterval) {
//        let currentTime = audioPlayer.currentTime
//        let newTime = currentTime + seconds
//        audioPlayer.seek(to: newTime)
//    }
//    func seekBackward(seconds: TimeInterval) {
//        let currentTime = audioPlayer.currentTime
//        let newTime = currentTime - seconds
//        audioPlayer.seek(to: newTime)
//    }
//    func getCurrentState() -> AudioPlayerState {
//        return audioPlayer.playerState
//    }
//    func getCurrentTime() -> TimeInterval? {
//        return audioPlayer.currentTime
//    }
//    func getTotalTime() -> TimeInterval? {
//        return audioPlayer.duration
//    }
//}


import AVFoundation

class CoughDetector {
    var coughDetectionHandler: (([[Float]],String) -> Void)?
    
    private var audioEngine: AVAudioEngine!
    private var audioFile: AVAudioFile?
    private var audioBuffer: AVAudioPCMBuffer?
    private var rollingBufferSize: AVAudioFramePosition = 44100 * 10  // Adjust as needed for your use case (10 seconds in this example)
    
    init() {
        self.audioEngine = AVAudioEngine()
    }
    
    func startRecording() {
        do {
            // Set up audio session
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("Error setting up audio session: \(error.localizedDescription)")
            }
            
            
            
            // Initialize audio engine
            let audioInputNode = audioEngine.inputNode
            let format = audioInputNode.inputFormat(forBus: 0)
            
            // Create a mixer node
            let mixer = audioEngine.mainMixerNode
            
            // Set the input gain (microphone sensitivity)
            let audioFormat = audioInputNode.inputFormat(forBus: 0)
            let inputGain = AVAudioUnitEQ(numberOfBands: 1)
            
            if let filterParams = inputGain.bands.first {
                filterParams.filterType = .highPass
                filterParams.frequency = 20.0  // Adjust the frequency as needed
                filterParams.bandwidth = 0.1   // Adjust the bandwidth as needed
                filterParams.gain = -20.0       // Adjust the gain to increase sensitivity
            }
            
            audioEngine.attach(inputGain)
            audioEngine.connect(audioInputNode, to: inputGain, format: audioFormat)
            audioEngine.connect(inputGain, to: mixer, format: audioFormat) // Connect to the mixer
            
            
            // Create a rolling buffer
            audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(rollingBufferSize))
            
            // Install a tap to continuously capture audio data
            audioInputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(rollingBufferSize), format: format) { (buffer, time) in
                self.processAudioBuffer(buffer)
            }
            
            
            
            // Start the audio engine
            try audioEngine.start()
        } catch {
            print("Error setting up the audio engine: \(error.localizedDescription)")
        }
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Implement your cough detection algorithm here
        if let audioBuffer = self.audioBuffer {
            audioBuffer.frameLength = buffer.frameLength
            memcpy(audioBuffer.floatChannelData![0], buffer.floatChannelData![0], Int(buffer.frameLength) * MemoryLayout<Float>.size)
            
            print("processAudioBuffer",audioBuffer.floatChannelData)
            
            let isCough = detectCoughInBuffer(audioBuffer)
            
            coughDetectionHandler?(isCough.2 ?? [] ,isCough.3)
            
        }
    }
    
    func detectCoughInBuffer(_ buffer: AVAudioPCMBuffer) -> ([String], Int, [[Float]]?,String) {
        
        let x = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
        let rsp = MyUserDefaults.getFloat(forKey: Constants.baseLineLoudness)
        
        let cc =  PythonFunctions.instance(array: x, fs: 22050, rsp: rsp,buffer: buffer)
        
        return cc
    }
    
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
