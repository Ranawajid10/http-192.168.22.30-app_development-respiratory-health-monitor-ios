//
//  BaselineVM.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 25/08/2023.
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



class BaselineVM:ObservableObject{
    
    @Published var scaleIn = false
    @Published var goNext = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var errorMessage = ""
    
    @Published var email = ""
    @Published var otp = 0
    
    @Published private var isRecording = false
    @Published private var audioRecorder: AVAudioRecorder!
    @Published private var audioFileURL: URL?
    @Published var  filePath: URL?
    
    @Published var counter = 0
    @Published var maxLoudness:Float = 0.0
    @Published var gotSample = false
    @Published var isTimerRunning = false
    @Published var remainingTime = 2
    @Published var segments:[[Float]] = []
    
    
    
    private var timer: Timer?
    private var cancellable: AnyCancellable?
    
    
    func doLogin(){
        
        isLoading = true
        
        
        ApiClient.shared.login(email: email, otp: otp) { [self] response in
            
            isLoading = false
            
            switch response {
            case .success(let success):
                
                if(success.statusCode==nil && (success.token != nil) && !(success.detail != nil)){
                    
                    isError = true
                    errorMessage = success.detail ?? ""
                    
                }else if(success.statusCode == 201 || success.statusCode == 200){
                    
                    //Logged In Successfully
                    MyUserDefaults.saveUserData(value: success)
                    MyUserDefaults.saveFloat(forKey: Constants.baseLineLoudness, value: maxLoudness)
                    MyUserDefaults.saveBool(forKey:Constants.isBaseLineSet, value: true)
                    MyUserDefaults.saveBool(forKey: Constants.isFirstSync, value: true)
                    isError = false
                    goNext = true
                    
                }
                
                break
                
            case .failure(let failure):
                isError = true
                errorMessage = failure.detail[0].msg ?? ""
                break
                
            }
            
            
        }
        
        
        
    }
    
    
    func startTimer() {
        
            Timer.scheduledTimer(withTimeInterval: 0.60, repeats: true) { [self] _ in
                
                if(isTimerRunning){
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.scaleIn.toggle()
                    }
                }else{
                    
                    self.timer?.invalidate()
                    
                }
            }

        
        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                //                withAnimation(.easeInOut(duration: 0.5)) {
                //
                //                    self.scaleIn.toggle()
                //
                //                }
                
                if self.counter < 2 {
                    self.counter += 1
                    self.remainingTime = 2 - self.counter
                    
                    
                    
                } else {
                    self.timer?.invalidate()
                    self.isTimerRunning = false
                    self.stopRecording() // Call the function when the timer ends
                }
            }
        
        
        requestMicrophonePermission() // Call the function when the timer starts
    }
    
    
    func requestMicrophonePermission() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            // Check for microphone permission
            recordingSession.requestRecordPermission { [weak self] allowed in
                guard let self = self else { return }
                if allowed {
                    DispatchQueue.main.async {
                        self.startRecording()
                    }
                } else {
                    // Handle the case where the user denied microphone permission
                    // You can show an alert or provide instructions to enable it in settings
                    self.gotSample = false
                    self.isError = true
                    self.errorMessage = "Microphone permission is required to record audio."
                    self.isTimerRunning = false
                    self.isRecording = false
                }
            }
        } catch {
            // Handle other errors, such as setting up the audio session
            self.gotSample = false
            self.isError = true
            self.errorMessage = "Failed to set up the audio session."
            self.isTimerRunning = false
            self.isRecording = false
        }
    }
    
    
    func startRecording(){
        
        isTimerRunning = true
        
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            
            gotSample = false
            isError = true
            errorMessage = "Can not setup the Recording"
            isTimerRunning = false
            isRecording = false
            
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("coughing_sample:1.m4a")
        
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
            
            gotSample = false
            isError = true
            errorMessage = "Failed to Setup the Recording"
            isTimerRunning = false
            isRecording = false
            
        }
        
        
        
    }
    
    
    func stopRecording(){
        
        if(isRecording){
            cancellable?.cancel()
            audioRecorder.stop()
            timer?.invalidate()
            isTimerRunning = false
            remainingTime = 2
            counter = 0
            
            
            DispatchQueue.main.async { [self] in
                
                coughBaseLineVerification()
                
            }
        }
        
    }
    
    
    deinit {
        cancellable?.cancel()
        
        timer?.invalidate()
        isTimerRunning = false
    }
    
    
    func coughBaseLineVerification(){
        
        
        do {
            let audioFile = try AVAudioFile(forReading: audioFileURL!)
            
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false)
            let frameCount = UInt32(audioFile.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: frameCount)
            try! audioFile.read(into: buffer!)
            
            let x = Array(UnsafeBufferPointer(start: buffer!.floatChannelData?[0], count: Int(frameCount)))
            let fs = Float(audioFile.fileFormat.sampleRate)
            
            
            (segments, _) = PythonFunctions.coughSegmentInference(audioData: x, fs: fs ,buffer:buffer!)
            
            
            if(segments.count > 0){
                
                maxLoudness = loudnessBasedAdaptive(segments: segments, buffer: buffer! )
                gotSample = true
                
            }else{
                
                print("elseo")
                errorMessage = "No cough found, Cough Louder Please!"
                gotSample = false
                isError = true
                
                
            }
            
        } catch {
            
            gotSample = false
            isError = true
            errorMessage = "Error reading cough sample. Please try again!"
            print("Error reading audio file: \(error.localizedDescription)")
            
        }
        
        
        
    }
    
    func loudnessBasedAdaptive(segments: [[Float]], sensitivity: Float = 4.0, sampleRate: Float = 22050.0,buffer: AVAudioPCMBuffer) -> Float {
        let maxLoudness = segments.map { PythonFunctions.powerByAVFoundation($0, sampleRate, buffer: buffer) }.max() ?? 0.0
        return maxLoudness
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
        
        print("in convertFloatAudioToWAV")
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
        
        let audioFile = try AVAudioFile(forWriting: filePath, settings: audioFormat!.settings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: AVAudioFrameCount(floatArray.count))
        buffer!.frameLength = AVAudioFrameCount(floatArray.count)
        
        for i in 0..<Int(buffer!.frameLength) {
            buffer!.floatChannelData![0][i] = floatArray[i]
        }
        
        print("in convertFloatAudioToWAV from loop")
        
        try audioFile.write(from: buffer!)
    }
    
    func playWAVFile(filePath: URL) {
        
        print("playWAVFile")
        
        do {
            
            print("do plyaay",filePath)
            
            
            let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    // Function to compute total energy
    
}
