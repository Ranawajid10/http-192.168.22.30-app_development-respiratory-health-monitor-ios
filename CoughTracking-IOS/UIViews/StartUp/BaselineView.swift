//
//  BaselineView.swift
//  CoughTracking-IOS
//
//  Created by ai4lyf on 18/08/2023.
//

import SwiftUI
import TensorFlowLite
import AVFoundation

struct BaselineView: View
{
    
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var baselineVM = BaselineVM()
    
    @State private var toast: FancyToast? = nil
    
    var body: some View{
        ZStack{
            VStack(spacing: 0){
                Image("logosmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 90)
                    .padding(.top, 10)
                    .alignmentGuide(.top) { dimension in
                        dimension[.top]
                    }
                Text("Cough Sample")
                    .foregroundColor(Color.black)
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .alignmentGuide(.top) { dimension in
                        dimension[.top]
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.leading,30)
                
                Text("Please give your first cough sample so that we can detect your coughs for future.\n\nNote:\n\n1. This cough sample recording is only for one time.\n\n2. Please record your loudest cough.")
                    .foregroundColor(Color("greycolor_text"))
                    .font(.system(size: 18))
                    .alignmentGuide(.top) { dimension in
                        dimension[.top]
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    .padding(.leading,30)
                
                Button(action: {
                    
                    baselineVM.startTimer()
                    
                }) {
                    Image("mic_recording")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 30)
                        .alignmentGuide(.bottom) { dimension in
                            dimension[.bottom]
                        }
                }
                
                HStack
                {
                    if (!baselineVM.isTimerRunning)
                    {
                        Text("Press the mic to start recording")
                            .foregroundColor(Color("greycolor_text"))
                            .font(.system(size: 18))
                            .padding(.top, 30)
                    }
                    else
                    {
                        Text(String(format: "%02d:%02d", baselineVM.remainingTime / 60, baselineVM.remainingTime % 60))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("blue_color"))
                        
                        Text("")
                    }
                    
                }
                .alignmentGuide(.top) { dimension in
                    dimension[.top]
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
                .padding(.leading, 0)
                
                
                
                Spacer()
                
                if(baselineVM.gotSample){
                    HStack(spacing: 120){
                        
                        Button {
                            
                            baselineVM.gotSample = false
                            
                        } label: {
                            
                            Text("Discard")
                                .foregroundColor(Color("red_color"))
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity)
                            
                        }
                        
                        
                        Button {
                            
                            if(baselineVM.gotSample){
                                
                                baselineVM.doLogin()
                                
                            }else{
                                
                                baselineVM.isError = true
                                baselineVM.errorMessage = "Something went wronge. Please cough again!"
                                
                            }
                            
                        } label: {
                            
                            Text("Next")
                                .foregroundColor(Color("blue_color"))
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity)
                            
                        }
                        
                    }
                }
            }
            
            if(baselineVM.isLoading){
                
                LoadingView()
                
            }
        }.onAppear{
            
            baselineVM.email = MyUserDefaults.getString(forKey: Constants.email)
            baselineVM.otp = MyUserDefaults.getInt(forKey: Constants.otp)
            
        }
        .environment(\.managedObjectContext,viewContext)
        .navigationDestination(isPresented: $baselineVM.goNext, destination: {
            
            DashboardView()
                .environment(\.managedObjectContext,viewContext)
                .environmentObject(networkManager)
            
        })
        .toastView(toast: $toast)
        .dismissKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
        .onReceive(baselineVM.$isError) { i in
            
            if(i){
                
                toast = FancyToast(type: .error, title: "Error occurred!", message: baselineVM.errorMessage)
                
            }
            
            
        }.onReceive(baselineVM.$gotSample) { i in
            
            if(i){
                
                toast = FancyToast(type: .success, title: "Success", message: "Cough sample detected successfully")
                
            }
            
            
        }
        
        
        
    }
    
    func saveCoughSample(){
        
        let baseLine = CoughBaseline(context: viewContext)
        
        baseLine.uid = "1"
        baseLine.createdOn = String(DateUtills.getCurrentTimeInMilliseconds())
        
        //        let floatArray: [Float] = [0.131, 0.3232, 1.4334, 0.4334, 0.3422, 0.434343]
        //        let data = try? NSKeyedArchiver.archivedData(withRootObject: floatArray, requiringSecureCoding: false)
        
        //        for segment in baselineVM.segments{
        //
        //            let coughSegment = CoughEntity(context:viewContext)
        //            coughSegment.value = segment
        //
        //            baseLine.addToCoughSegments(coughSegment)
        //
        //        }
        
        print("dsds",baselineVM.segments.count)
        //        baseLine.setSegments(baselineVM.segments)
        
        //        print("ddadadd",baseLine.getSegments())
        
        do {
            try viewContext.save()
            print("saved")
        } catch {
            // Handle the error
            print("Error saving data: \(error.localizedDescription)")
        }
        
        
    }
    
    
    
    //    func coughBaseLineVerification(){
    //
    ////        print("fdf")
    ////
    ////        let dirPath = "/Users/alirizwan/Desktop/iOSProjects/Cough-Monitoring-IOS"
    ////        let sys = Python.import("sys")
    ////        sys.path.append(Bundle.main.bundlePath)
    ////
    ////        if let segmentationModelPath = Bundle.main.path(forResource: "cough_baseline_verification", ofType: "py") {
    ////            let path = "file:///private/var/mobile/Containers/Data/Application/287DE1FF-7706-4B7F-AC36-F4B24FC18496/Documents/CO-Voice%20:%202023-08-24%2010:46:38%20+0000.m4a"
    ////
    ////
    ////            let coughBaselineVerification = Python.import("cough_baseline_verification")
    ////
    ////            let response = coughBaselineVerification.cough_baseline_verifications_new(path)
    ////
    ////
    ////            print("re",response)
    ////        }
    //
    //
    //        let path = "/var/mobile/Containers/Data/Application/2A80D192-5EDC-4AD0-82A3-C8F98C4D5718/Documents/coughing_sample:1223.m4a"
    //
    //
    //        guard let url = URL(string: path) else {
    //              print("Invalid file path")
    //            return
    //          }
    //
    //        do {
    //            let audioFile = try AVAudioFile(forReading: url)
    //            let audioFormat = audioFile.processingFormat
    //            let audioFrameCount = AVAudioFrameCount(audioFile.length)
    //
    //            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
    //            try audioFile.read(into: audioBuffer!)
    //
    ////            let segmentsAndProbs = coughSegmentInference(audioBuffer: audioBuffer)
    ////            let segments = segmentsAndProbs.0
    //
    //        } catch {
    //            print("Error reading audio file: \(error.localizedDescription)")
    //
    //        }
    //
    ////        let pathURL = URL(fileURLWithPath: path)
    ////        print("sdad",pathURL)
    ////        do {
    ////            let audioFile = try AVAudioFile(forReading: pathURL)
    ////            // Continue with audio processing
    ////
    ////
    ////            let audioFormat = audioFile.processingFormat
    ////            let audioFrameCount = UInt32((audioFile.length))
    ////            let audioData = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
    ////                do {
    ////                    try audioFile.read(into: audioData!)
    ////                } catch {
    ////                    print("Error reading audio file: \(error)")
    ////
    ////                }
    ////
    ////                // Convert audio data to an array of Float32
    ////                let audioSamples = Array(UnsafeBufferPointer(start: audioData?.floatChannelData?[0], count: Int(audioFrameCount)))
    ////
    ////
    ////            print("rere",audioSamples)
    ////
    ////
    ////
    ////
    ////        } catch let error as NSError {
    ////            print("Error opening audio file: \(error.localizedDescription)")
    ////        }
    //
    //
    //
    //    }
    
    
    
    
    //    struct BaselineView_Previews: PreviewProvider {
    //        static var previews: some View {
    //            BaselineView()
    //        }
    //    }
}
