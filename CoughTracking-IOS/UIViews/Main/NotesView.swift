//
//  NotesView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI
import AVFoundation




struct NotesView: View {
    
    @ObservedObject  var dashboardVM:DashboardVM
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @StateObject var notesVM = NotesVM()
    
    //    @State var delteNoteEntity = Notes()
    
    
    
    @FetchRequest(entity: CoughNotes.entity(), sortDescriptors: []) var audioChunks: FetchedResults<CoughNotes>
    @FetchRequest(entity: Notes.entity(), sortDescriptors: []) var notesFetchRequest: FetchedResults<Notes>
    
    
    @State var hours = [
        "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00",
        "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",
        "21:00", "22:00", "23:00"
    ]
    
    
    @State private var toast: FancyToast? = nil
    
    
    
    var body: some View {
        ZStack{
            VStack {
                
                DaySelectionView(notesVM: notesVM)
                    .foregroundColor(.black)
                    .padding(.top)
                
                ScrollView(showsIndicators: false) {
                    ForEach(Constants.notesHours, id: \.self){ hour in
                        
                        
                        NotesRowView(notesVM: notesVM, hour: hour)
                        
                        
                        
                    }.id(notesVM.updateRow)
                }
                
            }
            
            //            if(notesVM.isLoading){
            //
            //                LoadingView()
            //
            //            }
            
        }.toastView(toast: $toast)
            .background(Color.screenBG)
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $notesVM.showAddNoteSheet) {
                
                AddNoteSheetView(showNoteSheet: $notesVM.showAddNoteSheet, isNoteAdded: $notesVM.isNoteAdded,selectedDate:$notesVM.selectedDate,selectedHour:$notesVM.selectedHour)
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
                    .onDisappear{
                        
                        notesVM.isNoteAdded = false
                        
                    }
                
            }
            .sheet(isPresented: $notesVM.showCoughAndNoteSheet) {
                
                CoughsAndNotesSheetView(dashboardVM: dashboardVM,notesVM:notesVM)
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium,.large])
                
            }.onChange(of: notesVM.selectedDate) { oldValue, newValue in
                //
                //                updateRow+=1
                //                notesVM.currentDateCoughsList.removeAll()
                //                notesVM.currentDateNotesList.removeAll()
                
            }.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
                
                notesVM.audioChunks.removeAll()
                notesVM.notesFecthed.removeAll()
                
                notesVM.audioChunks = Array(audioChunks)
                notesVM.notesFecthed = Array(notesFetchRequest)
                
                
                notesVM.getCurrentDayCoughsAndNotes()
                
                notesVM.updateRow+=1
                
            }
        //            .onChange(of: notesVM.audioChunks) { oldValue, newValue in
        //
        //                notesVM.audioChunks.removeAll()
        //                notesVM.notesFecthed.removeAll()
        //
        //                notesVM.audioChunks = Array(audioChunks)
        //                notesVM.notesFecthed = Array(notesFetchRequest)
        //
        //
        //                notesVM.getCurrentDayCoughsAndNotes()
        //
        //                updateRow+=1
        //
        //            }.onChange(of: notesVM.notesFecthed) { oldValue, newValue in
        //
        //                notesVM.audioChunks.removeAll()
        //                notesVM.notesFecthed.removeAll()
        //
        //                notesVM.audioChunks = Array(audioChunks)
        //                notesVM.notesFecthed = Array(notesFetchRequest)
        //
        //
        //                notesVM.getCurrentDayCoughsAndNotes()
        //
        //                updateRow+=1
        //
        //            }
            .onChange(of: notesVM.isNoteAdded){ oldValue, newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .success, title: "Note Added!", message: "New note is add successfully")
                    
                }
                
            }.onChange(of: notesVM.isError){ oldValue, newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: notesVM.errorMessage)
                    
                }
                
            }.onAppear{
                
                notesVM.audioChunks.removeAll()
                notesVM.notesFecthed.removeAll()
                
                notesVM.audioChunks = Array(audioChunks)
                notesVM.notesFecthed = Array(notesFetchRequest)
                
                print("currentDateCoughsList",audioChunks.count,"----",notesVM.audioChunks.count)
                
                notesVM.userData = MyUserDefaults.getUserData() ??  LoginResult()
                
                
                notesVM.getCurrentDayCoughsAndNotes()
                
                
            }
        
    }
    
    
    
    
    
}


struct AddNoteSheetView:View{
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var note:String = ""
    @Binding var showNoteSheet:Bool
    @Binding var isNoteAdded:Bool
    @Binding var selectedDate:Date
    @Binding var selectedHour:String
    
    
    @State var isError:Bool = false
    @State var errorMessage:String = ""
    @State private var toast: FancyToast? = nil
    
    @State var dateString = ""
    
    
    var body: some View{
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            TextField("Type...", text: $note)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top,30)
            
            Button {
                
                saveNote()
                
            } label: {
                
                
                Text("Save")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width-60,height: 42)
                    .background(Color.appColorBlue)
                    .cornerRadius(40)
                
            }
            .padding(.top,24)
            
            
            Spacer()
            
            
        }.toastView(toast: $toast)
            .padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
            .onChange(of: isError){ oldValue, newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: errorMessage)
                    isError = false
                }
                
            }
    }
    
    
    func saveNote(){
        
        if(note.isEmpty){
            isError = true
            errorMessage = "Enter note first!"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        dateString = dateFormatter.string(from: selectedDate)
        
        
        let notes = Notes(context: viewContext)
        
        notes.id = DateUtills.getCurrentTimeInMilliseconds()
        notes.note = note
        notes.date = dateString
        notes.time = selectedHour
        
        do {
            
            try viewContext.save()
            
            saveUploadNotes()
            
            
        } catch {
            // Handle the error
            isError = true
            errorMessage = "Error saving data: \(error.localizedDescription)"
            print("Error saving data: \(error.localizedDescription)")
        }
        
    }
    
    func saveUploadNotes(){
        
        let uploadNotes = UploadNotes(context: viewContext)
        
        uploadNotes.id = DateUtills.getCurrentTimeInMilliseconds()
        uploadNotes.note = note
        uploadNotes.date = dateString
        uploadNotes.time = selectedHour
        
        do {
            
            try viewContext.save()
            
            note = ""
            
            showNoteSheet.toggle()
            isNoteAdded = true
            
            
        } catch {
            // Handle the error
            isError = true
            errorMessage = "Error saving data: \(error.localizedDescription)"
            print("Error saving data: \(error.localizedDescription)")
        }
        
    }
    
    
}

//struct NotesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotesView()
//    }
//}

struct NotesRowView: View {
    
    @ObservedObject var notesVM:NotesVM
    
    var hour:String
    
    
    @State var currentHourNotesList:[Notes] = []
    @State var currentHourCoughsList:[CoughNotes] = []
    
    
    @State var coughCount:Int = 0
    @State var notesCount:Int = 0
    
    @State var dashesHeight:CGFloat = 65.0
    
    var body: some View {
        
        HStack(alignment: .bottom){
            
            
            Text(hour)
                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                .foregroundColor(Color.black90)
                .padding(.bottom,2)
            
            
            
            VerticalDashedLine()
                .frame(height: dashesHeight)
            
            
            
            VStack(alignment: .leading){
                
                
                Button {
                    
                    withAnimation {
                        notesVM.selectedHour = hour+":00"
                        notesVM.showAddNoteSheet = true
                    }
                    
                    
                } label: {
                    
                    HStack{
                        
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 16,height:16)
                            .foregroundColor(.black)
                        
                        Text("Add note")
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            .foregroundColor(Color.black90)
                        
                        
                    }
                    
                }.padding(coughCount==0 ? .vertical : .top, coughCount==0 ? 16 : 8)
                
                
                
                if(coughCount>0){
                    
                    Button {
                        
                        notesVM.currentHourCoughsList.removeAll()
                        notesVM.currentHourCoughsList = currentHourCoughsList
                        
                        
                        notesVM.currentHourNotesList.removeAll()
                        notesVM.currentHourNotesList = currentHourNotesList
                        
                        
                        notesVM.showCoughAndNoteSheet.toggle()
                        
                    } label: {
                        
                        HStack{
                            
                            Text("\(coughCount) Coughs")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                                .foregroundColor(Color.appColorBlue)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 7,height: 12)
                                .foregroundColor(Color.appColorBlue)
                            
                        }.padding(.horizontal)
                            .frame(width: UIScreen.main.bounds.width-120,height: 45)
                            .background(Color.lightBlue)
                            .cornerRadius(5)
                        
                    }.padding(.top,8)
                    
                    
                    
                }
                
                if(notesCount>0){
                    
                    Button {
                        
                        notesVM.currentHourCoughsList.removeAll()
                        notesVM.currentHourCoughsList = currentHourCoughsList
                        
                        
                        notesVM.currentHourNotesList.removeAll()
                        notesVM.currentHourNotesList = currentHourNotesList
                        
                        
                        notesVM.showCoughAndNoteSheet.toggle()
                        
                    } label: {
                        
                        HStack{
                            
                            Text("\(notesCount) Notes")
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                                .foregroundColor(Color.appColorBlue)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 7,height: 12)
                                .foregroundColor(Color.appColorBlue)
                            
                        }.padding(.horizontal)
                            .frame(width: UIScreen.main.bounds.width-120,height: 45)
                            .background(Color.lightBlue)
                            .cornerRadius(5)
                        
                    }.padding(.top,8)
                    
                    
                    
                }
                
                Color.gray
                    .frame(height: 1)
                
                
            }
            
            
            
            
        }.padding(.horizontal)
            .onAppear{
                
                (currentHourCoughsList,currentHourNotesList) = notesVM.getCoughsAndNotesInThisHour(currentHour: hour, i: 1)
                
                //                currentHourCoughsList = notesVM.currentHourCoughsList
                //                currentHourNotesList = notesVM.currentHourNotesList
                
                //                coughCount = notesVM.currentHourCoughsList.count
                //                notesCount = notesVM.currentHourNotesList.count

                
                coughCount = currentHourCoughsList.count
                notesCount = currentHourNotesList.count
                
                if(coughCount>0||notesCount>0){
                    
                    dashesHeight = 110
                    
                }else if(coughCount>0 && notesCount>0){
                    
                    dashesHeight = 155
                    
                }else{
                    
                    dashesHeight = 65
                    
                }
                
            }
        //            .onReceive(notesVM.$currentHourCoughsList, perform: { value in
        //
        //                notesVM.getCoughsAndNotesInThisHour(currentHour: hour, i: 1)
        //
        //                currentHourCoughsList = notesVM.currentHourCoughsList
        //                currentHourNotesList = notesVM.currentHourNotesList
        //
        //                coughCount = notesVM.currentHourCoughsList.count
        //                notesCount = notesVM.currentHourNotesList.count
        //
        //            }).onReceive(notesVM.$currentHourNotesList, perform: { value in
        //
        //                notesVM.getCoughsAndNotesInThisHour(currentHour: hour, i: 1)
        //
        //                currentHourCoughsList = notesVM.currentHourCoughsList
        //                currentHourNotesList = notesVM.currentHourNotesList
        //
        //                coughCount = notesVM.currentHourCoughsList.count
        //                notesCount = notesVM.currentHourNotesList.count
        //
        //            })
        //            .onChange(of: notesVM.currentHourCoughsList) { oldValue, newValue in
        //
        //
        //
        //            }
        
        
    }
    
    
    
}


struct CoughsAndNotesSheetView:View{
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var note:String = ""
    @State var selectedIndex:Int = 0
    
    @ObservedObject  var dashboardVM:DashboardVM
    @ObservedObject  var notesVM:NotesVM
    
    @State var isFromApi:Bool = false
    
    var body: some View{
        
        VStack{
            
            ZStack{
                
                //                Color.black
                //                    .frame(width: 40,height: 3)
                //                    .cornerRadius(2)
                
                HStack{
                    
                    if( !isFromApi && selectedIndex == 0 && notesVM.currentHourCoughsList.count>0){
                        
                        Button {
                            
                            if(notesVM.selectedCoughsList.count != notesVM.currentHourCoughsList.count){
                                
                                notesVM.selectedCoughsList.removeAll()
                                notesVM.selectedCoughsList = notesVM.currentHourCoughsList
                                
                            }else{
                                
                                notesVM.selectedCoughsList.removeAll()
                                
                            }
                            
                            
                        } label: {
                            
                            HStack{
                                
                                Image(((notesVM.currentHourCoughsList.count>0) && (notesVM.selectedCoughsList.count == notesVM.currentHourCoughsList.count)) ? "checked" : "unchecked")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.appColorBlue)
                                
                                Text("Select All")
                                    .foregroundColor(Color.appColorBlue)
                                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                                
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    ForEach(0..<2){ index in
                        
                        
                        VStack {
                            
                            
                            Button {
                                
                                selectedIndex = index
                                
                            } label: {
                                
                                Text(index == 0 ? "Coughs" : "Notes")
                                    .foregroundColor(.black)
                                
                            }
                            
                            
                            
                            
                            if(selectedIndex == index){
                                
                                Color.appColorBlue
                                    .frame(width: 40, height: 2)
                                
                            }else{
                                
                                Color.clear
                                    .frame(width: 40, height: 1)
                                
                            }
                            
                            
                        }.padding(.trailing)
                        
                    }
                    
                }
            }
            
            if(selectedIndex == 0){
                
                CoughsNotesView(dashboardVM: dashboardVM,notesVM: notesVM,isFromApi: $isFromApi)
                
            }else{
                
                TextNotesView(notesVM: notesVM)
                    .environment(\.managedObjectContext, viewContext)
                
            }
            
            if(!notesVM.selectedCoughsList.isEmpty && selectedIndex == 0){
                
                Button {
                    
                    deleteSelectedCoughs()
                    
                } label: {
                    
                    
                    Text("Delete")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: UIScreen.main.bounds.width-100,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                    
                }
                .padding(.top,24)
                
            }
            
        }.padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
        
        
    }
    
    func deleteSelectedCoughs(){
        
        
        for cough in notesVM.selectedCoughsList{
            
            viewContext.delete(cough)
            
            do {
                
                try viewContext.save()
                
                if let index = notesVM.currentHourCoughsList.firstIndex(where: { $0.id == cough.id }){
                    
                    print("removed")
                    notesVM.currentHourCoughsList.remove(at: index)
                    
                    
                }else{
                    
                    print("unable to find item")
                    
                }
                
                if let index2 = notesVM.selectedCoughsList.firstIndex(where: { $0.id == cough.id }){
                    
                    print("removed")
                    notesVM.selectedCoughsList.remove(at: index2)
                    
                }else{
                    
                    print("unable to find item")
                    
                }
                
            } catch {
                
                print("Error deleting entity: \(error.localizedDescription)")
                
            }
            
        }
        
        notesVM.updateRow+=1
        
    }
    
    
}

struct MultiChannelWaveformView: View {
    let amplitudeData: [[Float]]
    var isPlaying:Bool
    @State private var playbackProgress: CGFloat = 0 // Add playback progress state
    private let lineSpacing: CGFloat = 1.0 // Add line spacing
    private let downsampleFactor: Int = 20 // Add downsampling factor
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<amplitudeData.count, id: \.self) { channelIndex in
                // Downsample the channel data
                let downsampledData = downsample(data: amplitudeData[channelIndex], factor: downsampleFactor)
                
                ZStack {
                    // Draw the entire waveform in blue
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(downsampledData.count - 1)
                        let midY = geometry.size.height / 2.0
                        
                        for (index, amplitude) in downsampledData.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = midY - CGFloat(amplitude) * midY + lineSpacing // Add line spacing
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue.opacity(0.30), lineWidth: 2)
                    
                    if(isPlaying){
                        // Draw a gradient overlay for the played portion
                        Path { path in
                            let stepX = geometry.size.width / CGFloat(downsampledData.count - 1)
                            let midY = geometry.size.height / 2.0
                            
                            for (index, amplitude) in downsampledData.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = midY - CGFloat(amplitude) * midY + lineSpacing // Add line spacing
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .trim(to: playbackProgress) // Trim the path based on playback progress
                        .stroke(Color.blue, lineWidth: 2) // Change the color to green
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .audioPlayerProgressNotification)) { notification in
            if let progress = notification.object as? CGFloat {
                withAnimation {
                    self.playbackProgress = progress
                }
            }
        }
    }
    
    // Function to downsample data
    private func downsample(data: [Float], factor: Int) -> [Float] {
        guard factor > 0 else {
            return data
        }
        
        var downsampledData: [Float] = []
        var sum: Float = 0
        
        for (index, amplitude) in data.enumerated() {
            sum += amplitude
            
            if index % factor == factor - 1 {
                downsampledData.append(sum / Float(factor))
                sum = 0
            }
        }
        
        return downsampledData
    }
}


struct CoughsNotesView:View{
    
    
    @ObservedObject  var dashboardVM:DashboardVM
    @ObservedObject  var notesVM:NotesVM
    @Binding var isFromApi:Bool
    
//    @State var isPlaying = false
    
    
    var body: some View{
        
        VStack{
            
            if(notesVM.currentHourCoughsList.count>0){
                ScrollView(showsIndicators: false) {
                    
                    ForEach(Array(notesVM.currentHourCoughsList.enumerated()), id: \.1.id) { (index, cough) in
                        
                        let coughSegments = cough.coughSegments ?? []
                        
                        HStack{
                            
                            if coughSegments.count > 0 && cough.url == ""{
                             
                                Button {
                                    
                                    if let selectedIndex = notesVM.selectedCoughsList.firstIndex(where: { $0.id == cough.id }) {
                                        
                                        notesVM.selectedCoughsList.remove(at: selectedIndex)
                                        
                                    } else {
                                        
                                        notesVM.selectedCoughsList.append(cough)
                                        
                                    }
                                    
                                } label: {
                                    
                                    Image(notesVM.selectedCoughsList.contains(where: { $0.id == cough.id }) ? "checked" : "unchecked")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color.appColorBlue)
                                    
                                }
                                
                            }
                            
                            
                            Text(cough.time ?? "")
                                .foregroundColor(Color.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                            
                            
                            HStack {
                                
                                Button {
                                    
                                    notesVM.playingPosition = index
                                    
                                    if(coughSegments.count == 0 && cough.url != ""){
                                        
//                                        notesVM.playingPosition = index
                                        
                                        print("playing index",index)
                                        
                                        if dashboardVM.isPlaying && notesVM.playingPosition == index {
                                            
                                            // Pause the remote url
                                            dashboardVM.pauseAudio()
                                            
                                        } else {
                                           
                                            // Play the remote url
                                            dashboardVM.playAudio(remoteURL: cough.url ?? "")
                                            
                                        }
                                        
                                    }else if (coughSegments.count > 0 && cough.url == ""){
                                        
                                       
                                        
                                        if dashboardVM.isPlaying && notesVM.playingPosition == index {
                                            
                                            // Pause the audio
                                            dashboardVM.pauseAudio()
                                            
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                // Play the audio
                                                dashboardVM.playSample(floatArray: coughSegments)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                } label: {
                                    
                                    if(coughSegments.count == 0 && cough.url != ""){
                                        
                                        if(notesVM.playingPosition == index && dashboardVM.remoteURLStatus == 1){
                                            
                                            ProgressView()
                                                .tint(Color.white)
                                            
                                        }else if(notesVM.playingPosition == index && dashboardVM.remoteURLStatus == 2){
                                            
                                            Image(systemName:"pause")
                                                .resizable()
                                                .frame(width: 10, height: 12)
                                                .foregroundColor(Color.white)
                                            
                                        }else if(dashboardVM.remoteURLStatus == 3 || dashboardVM.remoteURLStatus == 0 ){
                                            
                                            Image("play")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(Color.white)
                                            
                                        }else{
                                            
                                            Image("play")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(Color.white)
                                            
                                        }
                                        
                                    }else if (coughSegments.count > 0 && cough.url == ""){
                                        
                                        if(dashboardVM.isPlaying && notesVM.playingPosition == index){
                                            
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
                                    }
                                }.frame(width: 32,height: 32)
                                    .background(cough.coughPower == "moderate" ? Color.appColorBlue :Color.red )
                                    .cornerRadius(16)
                                
                                if(coughSegments.count == 0 && cough.url != ""){
                                    
                                    Image("waveform")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width-180, height: 35)
                                    
                                }else if (coughSegments.count > 0 && cough.url == ""){
                                    
                                    MultiChannelWaveformView(amplitudeData: coughSegments,isPlaying: index==notesVM.playingPosition)
                                    
                                }
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
                            .onAppear{
                                
                                if (coughSegments.count == 0 && cough.url != "") {
                                    
                                    isFromApi = true
                                    
                                }else{
                                    
                                    isFromApi = false
                                    
                                }
                                print("index",index)
                                
                            }
                        
                        
                    }
                }
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
                    
                }
                
            }
            
        }.padding(.top)
            .onReceive(NotificationCenter.default.publisher(for: .audioPlayerProgressNotification)) { notification in
                if let progress = notification.object as? CGFloat {
                    withAnimation {
                        
//                        if(progress<1.0){
//                            
//                            isPlaying = true
//                            
//                        }else{
//                            
//                            isPlaying = false
//                            
//                        }
//                        
                    }
                }
            }
        
    }
    
    
    
    
}

//class AudioPlayerManager: ObservableObject {
//    private var engine = AVAudioEngine()
//    private var player = AVAudioPlayerNode()
//
//    @Published var playbackProgress: Double = 0.0 // Publish playback progress
//    @Published var isPlaying: Bool = false
//
//
//    private var timer: Timer?
//
//    func playAudio(buffer: AVAudioPCMBuffer) {
//        do {
//            engine.attach(player)
//            engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
//
//            player.scheduleBuffer(buffer, completionHandler: nil)
//
//            try engine.start()
//
//            // Start the audio player
//            player.play()
//
//            // Create a timer to update playbackProgress in real-time
//            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//                guard let self = self else { return }
//                if self.player.isPlaying {
//                    if let lastRenderTime = self.player.lastRenderTime,
//                       let playerTime = self.player.playerTime(forNodeTime: lastRenderTime) {
//                        // Calculate the current playback progress within the range [0, 1]
//                        let currentTime = Double(playerTime.sampleTime) / Double(playerTime.sampleRate)
//                        let totalDuration = Double(buffer.frameLength) / buffer.format.sampleRate
//                        //                        let progress = min(1.0, max(0.0, currentTime / totalDuration))
//                        let progress = currentTime / totalDuration
//
//                        self.playbackProgress = progress
//
//                        print("adada",progress)
//
//                        self.isPlaying = true
//
//                        // Post the progress notification only if not completed
//
//                        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: progress)
//
//
//                        if progress > 1.0 {
//
//                            self.isPlaying = false
//                            self.timer?.invalidate()
//
//                        }
//                    }
//                } else {
//                    // Audio playback has finished, invalidate the timer
//                    self.isPlaying = false
//                    self.timer?.invalidate()
//                }
//            }
//        } catch {
//            self.isPlaying = false
//            print("Error playing audio: \(error.localizedDescription)")
//        }
//    }
//
//    func pauseAudio() {
//        player.pause()
//    }
//
//
//}


struct TextNotesView:View{
    
    @ObservedObject var notesVM:NotesVM
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var showDeleteAlert = false
    
    
    var body: some View{
        
        VStack{
            
            if(notesVM.currentHourNotesList.count>0){
                
                List {
                    
                    ForEach(notesVM.currentHourNotesList,id:\.self){ note in
                        
                        HStack{
                            
                            Text(note.note ?? "")
                                .foregroundColor(Color.black)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                .padding(.vertical)
                            
                            Spacer()
                            
                        }.listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        
                    }.onDelete(perform: deleteNote)
                    
                }.id(notesVM.updateRow)
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(Visibility.hidden)
                
                
            }
            else{
                
                VStack{
                    
                    Spacer()
                    
                    Image("no_data")
                        .resizable()
                        .frame(width: 150, height: 166)
                    
                    Text("Note Not Available")
                        .foregroundColor(Color.black)
                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                        .padding(.top)
                    
                    Spacer()
                    
                }
                
            }
            
            
            
        }.padding(.top)
        
    }
    
    func deleteNote(at offsets: IndexSet){
        
        for offset in offsets{
            
            let delteNoteEntity = notesVM.currentHourNotesList[offset]
            
            viewContext.delete(delteNoteEntity)
            
            notesVM.currentHourNotesList.remove(at: offset)
            
            notesVM.updateRow+=1
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting entity: \(error.localizedDescription)")
            }
            
        }
    }
    
    
}

struct DaySelectionView: View {
    
    @ObservedObject var notesVM:NotesVM
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    
    var body: some View {
        HStack {
            
            
            Button {
                
                if(!notesVM.isLoading){
                    withAnimation {
                        
                        notesVM.loadingPosition = 0
                        notesVM.previous()
                        
                    }
                }
                
            } label: {
                if(notesVM.isLoading && notesVM.loadingPosition == 0){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color.black)
                    
                }
            }
            
            Spacer()
            
            if(notesVM.isLoading && notesVM.loadingPosition == 2){
                
                ProgressView()
                    .tint(Color.black)
                
            }else{
                
                Text(DateUtills.isToday(notesVM.selectedDate) ? "Today" : dateFormatter.string(from: notesVM.selectedDate))
                    .foregroundColor(Color.black)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 18))
                
            }
            
            
            Spacer()
            
            Button {
                
                if(!notesVM.isLoading){
                    withAnimation {
                        
                        notesVM.loadingPosition = 1
                        notesVM.next()
                        
                    }
                }
                
            } label: {
                if(notesVM.isLoading && notesVM.loadingPosition == 1){
                    
                    ProgressView()
                        .tint(Color.black)
                    
                }else{
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(Color.black)
                    
                }
            }
            .disabled(Calendar.current.isDateInTomorrow(notesVM.selectedDate))
            
        }
        .padding(.horizontal, 32)
    }
    
    
}

//
//struct NotesView: View {
//
//    @ObservedObject  var dashboardVM:DashboardVM
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var selectedDate = Date()
//    @State private var showAddNoteSheet = false
//    @State private var showCoughAndNoteSheet = false
//    @State private var isNoteAdded = false
//    @State private var showNoteDeleteAlert = false
//    @State private var isError = false
//    @State private var errorMessage = ""
//    @State private var selectedHour = ""
////    @State var delteNoteEntity = Notes()
//
//    @State var hours = [
//        "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00",
//        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00",
//        "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00",
//        "21:00", "22:00", "23:00"
//    ]
//
//    @FetchRequest(entity: VolunteerCough.entity(), sortDescriptors: []) var audioChunks: FetchedResults<VolunteerCough>
//    @FetchRequest(entity: Notes.entity(), sortDescriptors: []) var notesFetchRequest: FetchedResults<Notes>
//
//
//    @State var currentDateCoughsList:[VolunteerCough] = []
//    @State var selectedCoughsList:[VolunteerCough] = []
//
//
//    @State var currentDateNotesList:[Notes] = []
//
//    @State var coughTimes: [String] = []
//
//    @State private var toast: FancyToast? = nil
//
//    @State var updateRow = 0
//
//    var body: some View {
//        VStack {
//
//            DaySelectionView(selectedDate: $selectedDate)
//                .foregroundColor(.black)
//
//            ScrollView(showsIndicators: false) {
//                ForEach(hours, id: \.self){ hour in
//
//                    let (currentDateCoughs,times) = getCurrentCoughs(hour: hour)
//                    let currentDateNotes = getCurrentNotes(hour: hour)
//
//                    NotesRowView(currentDateNotesList: $currentDateNotesList, currentDateCoughsList: $currentDateCoughsList, showCoughAndNoteSheet: $showCoughAndNoteSheet, showAddNoteSheet: $showAddNoteSheet, hour: hour, coughCount:  times.count, notesCount: currentDateNotes.count, currentDateCoughs: currentDateCoughs,selectedHour:$selectedHour, currentDateNotes: currentDateNotes)
//                        .onAppear{
//
//
//                            if(currentDateCoughsList.isEmpty){
//                                currentDateCoughsList = currentDateCoughs
//                            }
//
//                            if(currentDateNotesList.isEmpty){
//                                currentDateNotesList = currentDateNotes
//                            }
//
//
//                        }
//
//
//                }.id(updateRow)
//            }
//
//        }.toastView(toast: $toast)
//            .background(Color.screenBG)
//            .navigationTitle("Notes")
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showAddNoteSheet) {
//
//                AddNoteSheetView(showNoteSheet: $showAddNoteSheet, isNoteAdded: $isNoteAdded,selectedDate:$selectedDate,selectedHour:$selectedHour)
//                    .environment(\.managedObjectContext, viewContext)
//                    .presentationDetents([.medium])
//                    .onDisappear{
//
//                        isNoteAdded = false
//
//                    }
//
//            }
//            .sheet(isPresented: $showCoughAndNoteSheet) {
//
//                CoughsAndNotesSheetView(dashboardVM: dashboardVM, currentDateCoughsList: $currentDateCoughsList, currentDateNotesList: $currentDateNotesList, selectedCoughsList: $selectedCoughsList, updateNotesRow: $updateRow)
//                    .environment(\.managedObjectContext, viewContext)
//                    .presentationDetents([.medium,.large])
//
//            }.onChange(of: selectedDate) { newValue in
//
//                updateRow+=1
//                currentDateCoughsList.removeAll()
//                currentDateNotesList.removeAll()
//
//            }.onChange(of: isNoteAdded){ newValue in
//
//                if(newValue){
//
//                    toast = FancyToast(type: .success, title: "Note Added!", message: "New note is add successfully")
//
//                }
//
//            }.onChange(of: isError){ newValue in
//
//                if(newValue){
//
//                    toast = FancyToast(type: .error, title: "Error occurred!", message: errorMessage)
//
//                }
//
//            }
//
//    }
//
//
//    func getCurrentCoughs(hour:String) -> ([VolunteerCough],[String]){
//
//        var currentDateCoughsList:[VolunteerCough] = []
//
//        var coughTimes: [String] = []
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//
//        let dateString = dateFormatter.string(from: selectedDate)
//
//
//        for cough in audioChunks {
//
//            if cough.date == dateString {
//
//
//
//                let coughTime = cough.time?.components(separatedBy: ":").first ?? ""
//                let hour = hour.components(separatedBy: ":").first ?? ""
//
//                if(coughTime == hour){
//
//                    coughTimes.append(coughTime)
//                    currentDateCoughsList.append(cough)
//                }
//
//            }
//
//
//
//        }
//
//
//        return (currentDateCoughsList,coughTimes)
//    }
//
//    func getCurrentNotes(hour:String) -> [Notes] {
//
//        var currentDateNotesList:[Notes] = []
//
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//
//        let dateString = dateFormatter.string(from: selectedDate)
//
//
//        for notes in notesFetchRequest {
//
//            if notes.date == dateString {
//
//                let coughTime = notes.time?.components(separatedBy: ":").first ?? ""
//                let min = hour.components(separatedBy: ":").first ?? ""
//
//                if(coughTime == min){
//
//                    currentDateNotesList.append(notes)
//
//                }
//
//            }
//
//
//
//        }
//
//        let moderateList = currentDateNotesList.sorted { v1, v2 in
//
//            let a = v1.time?.dropLast(6) ?? "00"
//            let b = v2.time?.dropLast(6) ?? "00"
//
//            return a < b
//        }
//
//
//        return moderateList.reversed()
//    }
//
//
//}
//
//
//struct AddNoteSheetView:View{
//
//    @Environment(\.managedObjectContext) private var viewContext
//    @State var note:String = ""
//    @Binding var showNoteSheet:Bool
//    @Binding var isNoteAdded:Bool
//    @Binding var selectedDate:Date
//    @Binding var selectedHour:String
//
//
//    @State var isError:Bool = false
//    @State var errorMessage:String = ""
//    @State private var toast: FancyToast? = nil
//
//    var body: some View{
//
//        VStack{
//
//            Color.black
//                .frame(width: 40,height: 3)
//                .cornerRadius(2)
//
//
//            TextField("Type...", text: $note)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(8)
//                .padding(.horizontal)
//                .padding(.top,30)
//
//            Button {
//
//                saveNote()
//
//            } label: {
//
//
//                Text("Save")
//                    .font(.system(size: 16))
//                    .foregroundColor(Color.white)
//                    .frame(width: UIScreen.main.bounds.width-60,height: 42)
//                    .background(Color.appColorBlue)
//                    .cornerRadius(40)
//
//            }
//            .padding(.top,24)
//
//
//            Spacer()
//
//
//        }.toastView(toast: $toast)
//            .padding(.top)
//            .padding(.horizontal)
//            .background(Color.screenBG)
//            .onChange(of: isError){ newValue in
//
//                if(newValue){
//
//                    toast = FancyToast(type: .error, title: "Error occurred!", message: errorMessage)
//                    isError = false
//                }
//
//            }
//    }
//
//
//    func saveNote(){
//
//        if(note.isEmpty){
//            isError = true
//            errorMessage = "Enter note first!"
//            return
//        }
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//
//        let dateString = dateFormatter.string(from: selectedDate)
//
//
//        let notes = Notes(context: viewContext)
//
//        notes.id = DateUtills.getCurrentTimeInMilliseconds()
//        notes.note = note
//        notes.date = dateString
//        notes.time = selectedHour
//
//        do {
//
//            try viewContext.save()
//
//            note = ""
//
//            showNoteSheet.toggle()
//            isNoteAdded = true
//
//
//        } catch {
//            // Handle the error
//            isError = true
//            errorMessage = "Error saving data: \(error.localizedDescription)"
//            print("Error saving data: \(error.localizedDescription)")
//        }
//
//    }
//
//
//}
//
////struct NotesView_Previews: PreviewProvider {
////    static var previews: some View {
////        NotesView()
////    }
////}
//
//struct NotesRowView: View {
//
//    @Binding var currentDateNotesList:[Notes]
//    @Binding var currentDateCoughsList:[VolunteerCough]
//    @Binding var showCoughAndNoteSheet:Bool
//    @Binding var showAddNoteSheet:Bool
//    var hour:String
//    var coughCount:Int
//    var notesCount:Int
//    var currentDateCoughs:[VolunteerCough]
//    @Binding var selectedHour:String
//    var currentDateNotes:[Notes]
//
//    @State var dashesHeight:CGFloat = 65.0
//
//    var body: some View {
//
//        HStack(alignment: .bottom){
//
//
//            Text(hour)
//                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
//                .foregroundColor(Color.black90)
//                .padding(.bottom,2)
//
//
//
//            VerticalDashedLine()
//                .frame(height: dashesHeight)
//
//
//
//            VStack(alignment: .leading){
//
//
//                Button {
//
//                    withAnimation {
//                        selectedHour = hour+":00"
//                        showAddNoteSheet = true
//                    }
//
//
//                } label: {
//
//                    HStack{
//
//                        Image(systemName: "plus.circle")
//                            .resizable()
//                            .frame(width: 16,height:16)
//                            .foregroundColor(.black)
//
//                        Text("Add note")
//                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
//                            .foregroundColor(Color.black90)
//
//
//                    }
//
//                }.padding(coughCount==0 ? .vertical : .top, coughCount==0 ? 16 : 8)
//
//
//
//                if(coughCount>0){
//
//                    Button {
//
//                        currentDateCoughsList.removeAll()
//                        currentDateCoughsList = currentDateCoughs
//
//
//                        currentDateNotesList.removeAll()
//                        currentDateNotesList = currentDateNotes
//
//                        showCoughAndNoteSheet.toggle()
//
//                    } label: {
//
//                        HStack{
//
//                            Text("\(coughCount) Coughs")
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
//                                .foregroundColor(Color.appColorBlue)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .resizable()
//                                .frame(width: 7,height: 12)
//                                .foregroundColor(Color.appColorBlue)
//
//                        }.padding(.horizontal)
//                            .frame(width: UIScreen.main.bounds.width-120,height: 45)
//                            .background(Color.lightBlue)
//                            .cornerRadius(5)
//
//                    }.padding(.top,8)
//
//
//
//                }
//
//                if(notesCount>0){
//
//                    Button {
//
//                        currentDateCoughsList.removeAll()
//                        currentDateCoughsList = currentDateCoughs
//
//
//                        currentDateNotesList.removeAll()
//                        currentDateNotesList = currentDateNotes
//
//                        showCoughAndNoteSheet.toggle()
//
//                    } label: {
//
//                        HStack{
//
//                            Text("\(notesCount) Notes")
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
//                                .foregroundColor(Color.appColorBlue)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .resizable()
//                                .frame(width: 7,height: 12)
//                                .foregroundColor(Color.appColorBlue)
//
//                        }.padding(.horizontal)
//                            .frame(width: UIScreen.main.bounds.width-120,height: 45)
//                            .background(Color.lightBlue)
//                            .cornerRadius(5)
//
//                    }.padding(.top,8)
//
//
//
//                }
//
//                Color.gray
//                    .frame(height: 1)
//
//
//            }
//
//
//
//
//        }.padding(.horizontal)
//            .onAppear{
//
//                if(coughCount>0||notesCount>0){
//
//                    dashesHeight = 110
//
//                }else if(coughCount>0 && notesCount>0){
//
//                    dashesHeight = 155
//
//                }else{
//
//                    dashesHeight = 65
//
//                }
//
//            }
//
//
//    }
//
//
//
//}
//
//
//struct CoughsAndNotesSheetView:View{
//
//    @Environment(\.managedObjectContext) private var viewContext
//    @State var note:String = ""
//    @State var selectedIndex:Int = 0
//
//    @ObservedObject  var dashboardVM:DashboardVM
//    @Binding var currentDateCoughsList:[VolunteerCough]
//    @Binding var currentDateNotesList:[Notes]
//    @Binding var selectedCoughsList:[VolunteerCough]
//    @Binding var updateNotesRow:Int
//
//    var body: some View{
//
//        VStack{
//
//            ZStack{
//
//                //                Color.black
//                //                    .frame(width: 40,height: 3)
//                //                    .cornerRadius(2)
//
//                HStack{
//
//                    if(selectedIndex == 0 && currentDateCoughsList.count>0){
//
//                        Button {
//
//
//
//                            print((selectedCoughsList.count == currentDateCoughsList.count),"al")
//
//                            if(selectedCoughsList.count != currentDateCoughsList.count){
//
//                                selectedCoughsList.removeAll()
//                                selectedCoughsList = currentDateCoughsList
//
//                            }else{
//
//                                selectedCoughsList.removeAll()
//
//                            }
//
//
//                        } label: {
//
//                            HStack{
//
//                                Image(((currentDateCoughsList.count>0) && (selectedCoughsList.count == currentDateCoughsList.count)) ? "checked" : "unchecked")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(Color.appColorBlue)
//
//                                Text("Select All")
//                                    .foregroundColor(Color.appColorBlue)
//                                    .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
//
//                            }
//                        }
//
//                    }
//
//                    Spacer()
//
//                    ForEach(0..<2){ index in
//
//
//                        VStack {
//
//
//                            Button {
//
//                                selectedIndex = index
//
//                            } label: {
//
//                                Text(index == 0 ? "Coughs" : "Notes")
//                                    .foregroundColor(.black)
//
//                            }
//
//
//
//
//                            if(selectedIndex == index){
//
//                                Color.appColorBlue
//                                    .frame(width: 40, height: 2)
//
//                            }else{
//
//                                Color.clear
//                                    .frame(width: 40, height: 1)
//
//                            }
//
//
//                        }.padding(.trailing)
//
//                    }
//
//                }
//            }
//
//            if(selectedIndex == 0){
//
//                CoughsNotesView(dashboardVM: dashboardVM, currentDateCoughsList: $currentDateCoughsList, selectedCoughsList: $selectedCoughsList)
//
//            }else{
//
//                TextNotesView(currentDateNotesList: $currentDateNotesList)
//                    .environment(\.managedObjectContext, viewContext)
//
//            }
//
//            if(!selectedCoughsList.isEmpty && selectedIndex == 0){
//
//                Button {
//
//                    deleteSelectedCoughs()
//
//                } label: {
//
//
//                    Text("Delete")
//                        .font(.system(size: 16))
//                        .foregroundColor(Color.white)
//                        .frame(width: UIScreen.main.bounds.width-100,height: 42)
//                        .background(Color.appColorBlue)
//                        .cornerRadius(40)
//
//                }
//                .padding(.top,24)
//
//            }
//
//        }.padding(.top)
//            .padding(.horizontal)
//            .background(Color.screenBG)
//
//
//    }
//
//    func deleteSelectedCoughs(){
//
//
//        for cough in selectedCoughsList{
//
//            viewContext.delete(cough)
//
//            do {
//
//                try viewContext.save()
//
//                if let index = currentDateCoughsList.firstIndex(where: { $0.id == cough.id }){
//
//                    print("removed")
//                    currentDateCoughsList.remove(at: index)
//
//
//                }else{
//
//                    print("unable to find item")
//
//                }
//
//                if let index2 = selectedCoughsList.firstIndex(where: { $0.id == cough.id }){
//
//                    print("removed")
//                    selectedCoughsList.remove(at: index2)
//
//                }else{
//
//                    print("unable to find item")
//
//                }
//
//            } catch {
//
//                print("Error deleting entity: \(error.localizedDescription)")
//
//            }
//
//        }
//
//        updateNotesRow+=1
//
//    }
//
//
//}
//
//struct MultiChannelWaveformView: View {
//    let amplitudeData: [[Float]]
//    var isPlaying:Bool
//    @State private var playbackProgress: CGFloat = 0 // Add playback progress state
//    private let lineSpacing: CGFloat = 1.0 // Add line spacing
//    private let downsampleFactor: Int = 20 // Add downsampling factor
//
//    var body: some View {
//        GeometryReader { geometry in
//            ForEach(0..<amplitudeData.count, id: \.self) { channelIndex in
//                // Downsample the channel data
//                let downsampledData = downsample(data: amplitudeData[channelIndex], factor: downsampleFactor)
//
//                ZStack {
//                    // Draw the entire waveform in blue
//                    Path { path in
//                        let stepX = geometry.size.width / CGFloat(downsampledData.count - 1)
//                        let midY = geometry.size.height / 2.0
//
//                        for (index, amplitude) in downsampledData.enumerated() {
//                            let x = CGFloat(index) * stepX
//                            let y = midY - CGFloat(amplitude) * midY + lineSpacing // Add line spacing
//
//                            if index == 0 {
//                                path.move(to: CGPoint(x: x, y: y))
//                            } else {
//                                path.addLine(to: CGPoint(x: x, y: y))
//                            }
//                        }
//                    }
//                    .stroke(Color.blue.opacity(0.30), lineWidth: 2)
//
//                    if(isPlaying){
//                        // Draw a gradient overlay for the played portion
//                        Path { path in
//                            let stepX = geometry.size.width / CGFloat(downsampledData.count - 1)
//                            let midY = geometry.size.height / 2.0
//
//                            for (index, amplitude) in downsampledData.enumerated() {
//                                let x = CGFloat(index) * stepX
//                                let y = midY - CGFloat(amplitude) * midY + lineSpacing // Add line spacing
//
//                                if index == 0 {
//                                    path.move(to: CGPoint(x: x, y: y))
//                                } else {
//                                    path.addLine(to: CGPoint(x: x, y: y))
//                                }
//                            }
//                        }
//                        .trim(to: playbackProgress) // Trim the path based on playback progress
//                        .stroke(Color.blue, lineWidth: 2) // Change the color to green
//                    }
//                }
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .audioPlayerProgressNotification)) { notification in
//            if let progress = notification.object as? CGFloat {
//                withAnimation {
//                    self.playbackProgress = progress
//                }
//            }
//        }
//    }
//
//    // Function to downsample data
//    private func downsample(data: [Float], factor: Int) -> [Float] {
//        guard factor > 0 else {
//            return data
//        }
//
//        var downsampledData: [Float] = []
//        var sum: Float = 0
//
//        for (index, amplitude) in data.enumerated() {
//            sum += amplitude
//
//            if index % factor == factor - 1 {
//                downsampledData.append(sum / Float(factor))
//                sum = 0
//            }
//        }
//
//        return downsampledData
//    }
//}
//
//
//struct CoughsNotesView:View{
//
//
//    @ObservedObject  var dashboardVM:DashboardVM
//    @Binding var currentDateCoughsList:[VolunteerCough]
//    @Binding var selectedCoughsList:[VolunteerCough]
//
//
//    @State var isPlaying = false
//    @State var playingPosition = 0
//
//    var body: some View{
//
//        VStack{
//
//            if(currentDateCoughsList.count>0){
//                ScrollView(showsIndicators: false) {
//
//                    ForEach(Array(currentDateCoughsList.enumerated()), id: \.1.id) { (index, cough) in
//
//
//                        HStack{
//
//                            Button {
//
//                                if let selectedIndex = selectedCoughsList.firstIndex(where: { $0.id == cough.id }) {
//
//                                    selectedCoughsList.remove(at: selectedIndex)
//
//                                } else {
//
//                                    selectedCoughsList.append(cough)
//
//                                }
//
//                            } label: {
//
//                                Image(selectedCoughsList.contains(where: { $0.id == cough.id }) ? "checked" : "unchecked")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(Color.appColorBlue)
//
//                            }
//
//
//
//                            Text(cough.time ?? "")
//                                .foregroundColor(Color.black)
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
//
//
//                            HStack {
//
//                                Button {
//
//                                    playingPosition = index
//
//                                    if isPlaying && playingPosition == index {
//
//                                        // Pause the audio
//                                        dashboardVM.pauseAudio()
//
//                                    } else {
//
//                                        // Play the audio
//                                        dashboardVM.playSample(floatArray: cough.coughSegments ?? [])
//
//                                    }
//
//                                } label: {
//
//                                    if(isPlaying && playingPosition == index){
//
//                                        Image(systemName:"pause")
//                                            .resizable()
//                                            .frame(width: 10, height: 12)
//                                            .foregroundColor(Color.white)
//
//                                    }else{
//
//                                        Image("play")
//                                            .resizable()
//                                            .frame(width: 18, height: 18)
//                                            .foregroundColor(Color.white)
//
//                                    }
//
//                                }.frame(width: 32,height: 32)
//                                    .background(cough.coughPower == "moderate" ? Color.appColorBlue :Color.red )
//                                    .cornerRadius(16)
//
//
//                                MultiChannelWaveformView(amplitudeData: cough.coughSegments ?? [],isPlaying: index==playingPosition)
//
//                            }.padding(.all,8)
//                                .background(Color.white)
//                                .cornerRadius(24)
//                                .padding(.leading,4)
//
//                            //                            Spacer()
//                            //
//                            //                            Button {
//                            //
//                            //
//                            //                            } label: {
//                            //
//                            //                                Image(systemName: "ellipsis")
//                            //                                    .rotationEffect(Angle(degrees: 90))
//                            //                                    .foregroundColor(Color.appColorBlue)
//                            //
//                            //                            }
//
//
//                        }.padding(.bottom)
//
//
//                    }
//                }
//            }else{
//
//                VStack{
//
//                    Spacer()
//
//                    Image("no_recordings")
//                        .resizable()
//                        .frame(width: 150, height: 166)
//
//                    Text("No Recordings Available")
//                        .foregroundColor(Color.black)
//                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
//                        .padding(.top)
//
//                    Spacer()
//
//                }
//
//            }
//
//        }.padding(.top)
//            .onReceive(NotificationCenter.default.publisher(for: .audioPlayerProgressNotification)) { notification in
//                if let progress = notification.object as? CGFloat {
//                    withAnimation {
//
//                        if(progress<1.0){
//
//                            isPlaying = true
//
//                        }else{
//
//                            isPlaying = false
//
//                        }
//
//                    }
//                }
//            }
//
//
//    }
//
//
//
//
//}
//
////class AudioPlayerManager: ObservableObject {
////    private var engine = AVAudioEngine()
////    private var player = AVAudioPlayerNode()
////
////    @Published var playbackProgress: Double = 0.0 // Publish playback progress
////    @Published var isPlaying: Bool = false
////
////
////    private var timer: Timer?
////
////    func playAudio(buffer: AVAudioPCMBuffer) {
////        do {
////            engine.attach(player)
////            engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
////
////            player.scheduleBuffer(buffer, completionHandler: nil)
////
////            try engine.start()
////
////            // Start the audio player
////            player.play()
////
////            // Create a timer to update playbackProgress in real-time
////            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
////                guard let self = self else { return }
////                if self.player.isPlaying {
////                    if let lastRenderTime = self.player.lastRenderTime,
////                       let playerTime = self.player.playerTime(forNodeTime: lastRenderTime) {
////                        // Calculate the current playback progress within the range [0, 1]
////                        let currentTime = Double(playerTime.sampleTime) / Double(playerTime.sampleRate)
////                        let totalDuration = Double(buffer.frameLength) / buffer.format.sampleRate
////                        //                        let progress = min(1.0, max(0.0, currentTime / totalDuration))
////                        let progress = currentTime / totalDuration
////
////                        self.playbackProgress = progress
////
////                        print("adada",progress)
////
////                        self.isPlaying = true
////
////                        // Post the progress notification only if not completed
////
////                        NotificationCenter.default.post(name: .audioPlayerProgressNotification, object: progress)
////
////
////                        if progress > 1.0 {
////
////                            self.isPlaying = false
////                            self.timer?.invalidate()
////
////                        }
////                    }
////                } else {
////                    // Audio playback has finished, invalidate the timer
////                    self.isPlaying = false
////                    self.timer?.invalidate()
////                }
////            }
////        } catch {
////            self.isPlaying = false
////            print("Error playing audio: \(error.localizedDescription)")
////        }
////    }
////
////    func pauseAudio() {
////        player.pause()
////    }
////
////
////}
//
//
//struct TextNotesView:View{
//
//    @Binding var currentDateNotesList:[Notes]
//
//    @Environment(\.managedObjectContext) private var viewContext
//    @State var showDeleteAlert = false
//
//
//    var body: some View{
//
//        VStack{
//
//            if(currentDateNotesList.count>0){
//
//                List {
//
//                    ForEach(currentDateNotesList,id:\.self){ note in
//
//                        HStack{
//
//                            Text(note.note ?? "")
//                                .foregroundColor(Color.black)
//                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
//                                .padding(.vertical)
//
//                            Spacer()
//
//                        }.listRowInsets(EdgeInsets())
//                            .listRowBackground(Color.clear)
//
//
//                    }.onDelete(perform: deleteNote)
//
//                }.listStyle(PlainListStyle())
//                    .scrollContentBackground(Visibility.hidden)
//
//
//            }
//            else{
//
//                VStack{
//
//                    Spacer()
//
//                    Image("no_data")
//                        .resizable()
//                        .frame(width: 150, height: 166)
//
//                    Text("Note Not Available")
//                        .foregroundColor(Color.black)
//                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
//                        .padding(.top)
//
//                    Spacer()
//
//                }
//
//            }
//
//
//
//        }.padding(.top)
//
//    }
//
//    func deleteNote(at offsets: IndexSet){
//
//        for offset in offsets{
//
//            let delteNoteEntity = currentDateNotesList[offset]
//
//            viewContext.delete(delteNoteEntity)
//
//            do {
//                try viewContext.save()
//            } catch {
//                print("Error deleting entity: \(error.localizedDescription)")
//            }
//
//        }
//    }
//
//
//}
//
//struct DaySelectionView: View {
//
//    @Binding var selectedDate:Date
//
//    var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }
//
//
//    var body: some View {
//        HStack {
//
//
//            Button {
//
//                withAnimation {
//
//                    previous()
//
//                }
//
//            } label: {
//                Image(systemName: "chevron.backward")
//                    .foregroundColor(Color.black)
//            }
//
//            Spacer()
//
//            Text(isToday(selectedDate) ? "Today" : dateFormatter.string(from: selectedDate))
//
//
//            Spacer()
//
//            Button {
//
//                withAnimation {
//
//                    next()
//
//                }
//
//            } label: {
//                Image(systemName: "chevron.forward")
//                    .foregroundColor(Color.black)
//            }
//            .disabled(Calendar.current.isDateInTomorrow(selectedDate))
//
//        }
//        .padding(.horizontal, 32)
//    }
//
//    func next(){
//
//        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
//        if tomorrow <= Date() {
//            selectedDate = tomorrow
//        }
//
//    }
//
//    func previous(){
//
//        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
//
//    }
//
//
//    func isToday(_ date: Date) -> Bool {
//        return Calendar.current.isDate(date, inSameDayAs: Date())
//    }
//}
