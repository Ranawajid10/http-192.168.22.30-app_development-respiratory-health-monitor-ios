//
//  ClearHistoryView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 24/08/2023.
//

import SwiftUI

struct ClearHistoryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Cough.entity(), sortDescriptors: []) var coughFetchResult: FetchedResults<Cough>
    @FetchRequest(entity: CoughNotes.entity(), sortDescriptors: []) var coughNotesFetchResult: FetchedResults<CoughNotes>
    @FetchRequest(entity: HoursUpload.entity(), sortDescriptors: []) var hoursUploadFetchResult: FetchedResults<HoursUpload>
    @FetchRequest(entity: Notes.entity(), sortDescriptors: []) var notesFetchResult: FetchedResults<Notes>
    @FetchRequest(entity: TrackedHours.entity(), sortDescriptors: []) var trackedHourFetchResult: FetchedResults<TrackedHours>
    @FetchRequest(entity: VolunteerCough.entity(), sortDescriptors: []) var volunteerCoughFetchResult: FetchedResults<VolunteerCough>
    
    
    @State var isLoading = false
    @State var isCleared = false
    
    
    @State var isRangeExpended = false
    @State var showAlert = false
    @State var selectedRange = "Select Range"
    @State var days = 0
    
    @State private var toast: FancyToast? = nil
    
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Text("Time range")
                        .foregroundColor(.black)
                        .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    Spacer()
                }
                
                DisclosureGroup(selectedRange, isExpanded: $isRangeExpended) {
                    
                    ForEach(0..<Constants.clearHistoryList.count,id: \.self){ index in
                        
                        Button {
                            
                            withAnimation {
                                isRangeExpended.toggle()
                                selectedRange = Constants.clearHistoryList[index]
                               
                                if(index==0){
                               
                                    days = 7
                               
                                }else if(index==1){
                               
                                    days = 14
                               
                                }else if(index==2){
                                
                                    days = 30
                               
                                }
                                
                            }
                            
                        } label: {
                            
                            HStack {
                                
                                Text(Constants.clearHistoryList[index])
                                    .foregroundColor(.black)
                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                                    .padding(.top)
                                
                                Spacer()
                            }
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                }.foregroundColor(.black)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    .padding(.all,15)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.top)
                
                
                Button {
                    
                    showAlert.toggle()
                    
                } label: {
                    
                    
                    Text("Clear")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white)
                        .frame(width: UIScreen.main.bounds.width-40,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                    
                    
                }
                .padding(.top,50)
                
                
                Spacer()
            }
            
            
            if(isLoading){
                
                LoadingView()
                
            }
            
        }.toastView(toast: $toast)
        .padding()
            .navigationTitle("Clear History")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.screenBG)
            .customAlert(isPresented: $showAlert) {
                
                CustomAlertView(
                    showVariable: $showAlert, showTwoButton: true, message: "Are you sure you want to clear history?",
                    action: {
                        DispatchQueue.main.async{ [self] in
                         
                            clearOneWeekData(olderThanDays: days)
                            
                        }
                    }
                )
                
            }.onChange(of: isCleared, { oldValue, newValue in
               
                if(newValue){
                    
                    toast = FancyToast(type: .success, title: "Success", message: "History Cleared Successfully")
                    isCleared = false
                    
                }
                
            })
           
    }
    
    func clearOneWeekData(olderThanDays: Int){
        
        isLoading  = true
        isCleared  = false
        
        let currentDate = DateUtills.getCurrentDate(format: DateTimeFormats.dateFormat1)
        
        let olderDate = Calendar.current.date(byAdding: .day, value: -olderThanDays, to: currentDate)!
        
        print("olderDate",olderDate)
        
        
        for cough in coughFetchResult{
            
            if let date = cough.date{
                
                let coughDate = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateFormat1)
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(cough)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("cough Error deleting data: \(error.localizedDescription)")
                    }
                }
                
                
                
            }
        }
        
        for coughNotes in coughNotesFetchResult{
            
            if let date = coughNotes.date{
                
                let coughDate = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateFormat1)
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(coughNotes)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("coughNotes Error deleting data: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
        
        for hoursUpload in hoursUploadFetchResult{
            
            if let date = hoursUpload.dateTime{
                
                let d = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateTimeFormat1)
                
                let coughDate = DateUtills.changeDateFormat(date: d, newFormat: DateTimeFormats.dateFormat1)!
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(hoursUpload)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("hoursUpload Error deleting data: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
        
        for notes in notesFetchResult{
            
            if let date = notes.date{
                
                let coughDate = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateFormat1)
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(notes)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("coughNotes Error deleting data: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
        
        for trackedHour in trackedHourFetchResult{
            
            if let date = trackedHour.date{
                
                let d = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateTimeFormat1)
                
                let coughDate = DateUtills.changeDateFormat(date: d, newFormat: DateTimeFormats.dateFormat1)!
                
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(trackedHour)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("coughNotes Error deleting data: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
        
        
        for volunteerCough in volunteerCoughFetchResult{
            
            if let date = volunteerCough.date{
                
                let coughDate = DateUtills.stringToDate(date: date, dateFormat: DateTimeFormats.dateFormat1)
                
                if(coughDate<=currentDate || coughDate>=olderDate){
                    
                    do {
                        PersistenceController.shared.container.viewContext.delete(volunteerCough)
                        try  PersistenceController.shared.container.viewContext.save()
                        
                    }catch {
                        print("coughNotes Error deleting data: \(error.localizedDescription)")
                    }
                    
                }
                
                
            }
        }
        
        isCleared  = true
        isLoading  = false
    }
}

struct ClearHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClearHistoryView()
    }
}
