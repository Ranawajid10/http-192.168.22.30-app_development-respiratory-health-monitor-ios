//
//  VolunteerParticipationView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 24/08/2023.
//

import SwiftUI
import AVFoundation

struct VolunteerParticipationView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject  var dashboardVM:DashboardVM
    @FetchRequest(entity: VolunteerCough.entity(), sortDescriptors: []) var allCoughFetchResult: FetchedResults<VolunteerCough>
    
   
    @State private var toast: FancyToast? = nil
    
    @StateObject var vpVM = VolunteerParticipationVM()
    
    @State var isPlaying = false
    @State var playingPosition = 0
    @State var allCoughCount = 0
    
    var body: some View {
        ZStack {
            
            if(allCoughCount>0){
                
                VStack {
                    Text("To ensure the privacy of out users, we are displaying all the coughs till now so that our users can hear them before uploading them to the cloud.")
                        .foregroundColor(Color.black)
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    
                    HStack{
                        
                        Button {
                            
                            if(vpVM.selectedCoughsList.count != vpVM.allCoughList.count){
                                
                                vpVM.selectedCoughsList.removeAll()
                                vpVM.selectedCoughsList = Array(vpVM.allCoughList)
                                
                            }else{
                                
                                vpVM.selectedCoughsList.removeAll()
                                
                            }
                            
                        } label: {
                            
                            HStack{
                                
                                Image(((vpVM.allCoughList.count>0) && (vpVM.selectedCoughsList.count == vpVM.allCoughList.count)) ? "selection_selected" : "selection")
                                    .resizable()
                                    .frame(width: 24,height: 24)
                                
                                Text("Select all")
                                    .foregroundColor(.appColorBlue)
                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                
                                
                            }
                            
                        }.padding(.leading,10)
                            .padding(.top,30)
                        
                        Spacer()
                        
                        
                    }
                    
                    ScrollView(showsIndicators: false) {
                        ForEach(Array(vpVM.allCoughList.enumerated()), id: \.1.id) { (index, cough) in
                            
                            VStack{
                                
                                HStack {
                                    Button {
                                        
                                        if let selectedIndex = vpVM.selectedCoughsList.firstIndex(where: { $0.id == cough.id }) {
                                            
                                            vpVM.selectedCoughsList.remove(at: selectedIndex)
                                            
                                        } else {
                                            
                                            vpVM.selectedCoughsList.append(cough)
                                            
                                        }
                                        
                                    } label: {
                                        
                                        HStack{
                                            
                                            
                                            Image(vpVM.selectedCoughsList.contains(where: { $0.id == cough.id }) ? "checked" : "unchecked")
                                                .resizable()
                                                .frame(width: 24,height: 24)
                                                .foregroundColor(Color.appColorBlue)
                                            
                                            Text(cough.date ?? "")
                                                .foregroundColor(.appColorBlue)
                                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                            
                                            
                                        }
                                        
                                    }
                                    Spacer()
                                    
                                }
                                
                                
                                HStack{
                                    
                                    
                                    
                                    Text(cough.time ?? "")
                                        .foregroundColor(Color.black)
                                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                                    
                                    
                                    HStack {
                                        
                                        Button {
                                            
                                            playingPosition = index
                                            
                                            if isPlaying && playingPosition == index {
                                                
                                                // Pause the audio
                                                dashboardVM.pauseAudio()
                                                
                                            } else {
                                                
                                                // Play the audio
                                                dashboardVM.playSample(floatArray: cough.coughSegments ?? [])
                                                
                                            }
                                            
                                        } label: {
                                            
                                            if(isPlaying && playingPosition == index){
                                                
                                                Image(systemName:"pause")
                                                    .resizable()
                                                    .frame(width: 10, height: 12)
                                                    .foregroundColor(Color.white)
                                                
                                            }else{
                                                
                                                Image("play")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(Color.white)
                                                
                                            }
                                            
                                        }.frame(width: 32,height: 32)
                                            .background(cough.coughPower == "moderate" ? Color.appColorBlue :Color.red )
                                            .cornerRadius(16)
                                        
                                        
                                        MultiChannelWaveformView(amplitudeData: cough.coughSegments ?? [],isPlaying: index==playingPosition)
                                        
                                    }.padding(.all,8)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                        .padding(.leading,4)
                                    
                                    //                            Spacer()
                                    //
                                    //                            Button {
                                    //
                                    //
                                    //                            } label: {
                                    //
                                    //                                Image(systemName: "ellipsis")
                                    //                                    .rotationEffect(Angle(degrees: 90))
                                    //                                    .foregroundColor(Color.appColorBlue)
                                    //
                                    //                            }
                                    
                                    
                                }.padding(.bottom)
                                
                                
                                //                            HStack{
                                //
                                //                                Text(cough.time ?? "")
                                //                                    .foregroundColor(Color.black)
                                //                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                                //
                                //
                                //                                HStack {
                                //
                                //                                    Button {
                                //
                                //
                                //                                    } label: {
                                //
                                //                                        Image("play")
                                //                                            .resizable()
                                //                                            .frame(width: 18, height: 18)
                                //                                            .foregroundColor(Color.white)
                                //
                                //                                    }.frame(width: 32,height: 32)
                                //                                        .background(Color.appColorBlue)
                                //                                        .cornerRadius(16)
                                //
                                //
                                //                                    Image("waveform")
                                //
                                //                                }.padding(.all,8)
                                //                                .background(Color.white)
                                //                                .cornerRadius(24)
                                //                                .padding(.leading)
                                //
                                //                               Spacer()
                                //
                                //                                Button {
                                //
                                //
                                //                                } label: {
                                //
                                //                                    Image(systemName: "ellipsis")
                                //                                        .rotationEffect(Angle(degrees: 90))
                                //                                        .foregroundColor(Color.appColorBlue)
                                //
                                //                                }
                                //
                                //
                                //                            }
                                
                                
                            }
                            
                            
                        }.padding(.horizontal,5)
                        
                    }.padding(.top,32)
                    
                    Button {
                        
                        if(vpVM.selectedCoughsList.count==0){
                           
                            if(vpVM.allCoughList.count==0){
                                
                                vpVM.isError = true
                                vpVM.errorMessage = "No Samples found"
                                
                            }else{
                                
                                vpVM.donateSamples()
                                
                            }
                        
                            
                        }else{
                        
                            deleteSelectedCoughs()
                            
                        }
                        
                    } label: {
                        
                        
                        Text(vpVM.selectedCoughsList.count == 0 ? "Donate Samples" : "Delete")
                            .foregroundColor(Color.white)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        
                        
                    }.frame(width: UIScreen.main.bounds.width-40,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                    
                    
                }.padding()
                
            }else{
                
                VStack{
                    
                    Spacer()
                    
                    Image("no_recordings")
                        .resizable()
                        .frame(width: 150, height: 166)
                    
                    Text("No Recordings Available")
                        .foregroundColor(Color.black)
                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                        .padding(.top)
                    
                    Spacer()
                    
                }.frame(width: UIScreen.main.bounds.width)
                
            }
        }
        .onAppear{
           
            vpVM.allCoughList = Array(allCoughFetchResult)
            
            allCoughCount = vpVM.allCoughList.count
            
        }.toastView(toast: $toast)
        .background(Color.screenBG)
        .navigationTitle("Volunteer Participation")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vpVM.isError){ oldValue, newValue in
            
            if(newValue){
                
                toast = FancyToast(type: .error, title: "Error occurred!", message: vpVM.errorMessage)
                vpVM.isError = false
            }
            
        }
    }
    
    func deleteSelectedCoughs(){
        
        
        for cough in vpVM.selectedCoughsList{
            
            viewContext.delete(cough)
            
            do {
                
                try viewContext.save()
               
                if let index = vpVM.allCoughList.firstIndex(where: { $0.id == cough.id }){
                    
                    print("removed")
                    vpVM.allCoughList.remove(at: index)
                   
                    
                }else{
                    
                    print("unable to find item")
                    
                }
                
                if let index2 = vpVM.selectedCoughsList.firstIndex(where: { $0.id == cough.id }){
                    
                    print("removed")
                    vpVM.selectedCoughsList.remove(at: index2)
                    
                }else{
                    
                    print("unable to find item")
                    
                }
                
            } catch {
                
                print("Error deleting entity: \(error.localizedDescription)")
                
            }
            
        }
        
//        updateNotesRow+=1
        
    }
    
   
    
}

//struct VolunteerParticipationView_Previews: PreviewProvider {
//    static var previews: some View {
//        VolunteerParticipationView(allCoughList: <#Binding<[Cough]>#>)
//    }
//}
