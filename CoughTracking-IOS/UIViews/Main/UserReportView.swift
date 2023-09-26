//
//  UserReportView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI
import Combine
import Foundation
import UserNotifications
import QuickLook

struct UserReportView: View {
    
    @State var showDownloadAlert = false
    
    @State private var progress: Double = 0.0
    @State private var isDownloading = false
    @State private var isShowingPDF = false
    
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("CoughTrackReports.pdf")
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    
                    Image("report")
                        .resizable()
                        .frame(width: 24,height: 24)
                    
                    Text("Your Cough Report")
                        .foregroundColor(.black)
                        .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                    
                    Spacer()
                    
                }
                
                
                Text("Your report will show a graph of your coughs over a period of one, two or three months.")
                    .foregroundColor(.darkBlue)
                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                    .padding(.horizontal,22)
                
                
                Button {
                    
                    showDownloadAlert.toggle()
                    
                } label: {
                    
                    
                    HStack {
                        
                        Image("downloads")
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text("Download PDF")
                            .modifier(LatoFontModifier(fontWeight: .bold, fontSize: 16))
                            .foregroundColor(Color.white)
                    }.frame(width: UIScreen.main.bounds.width-60,height: 42)
                        .background(Color.appColorBlue)
                        .cornerRadius(40)
                    
                    
                }
                .padding(.top)
                
                
                Spacer()
                
            }.padding()
            
            if isDownloading {
                LoadingView()
            }
            
        }.navigationTitle("User Report")
            .navigationBarTitleDisplayMode(.inline)
            .customAlert(isPresented: $showDownloadAlert) {
                
                CustomAlertView(
                    showVariable: $showDownloadAlert, showTwoButton: true, message: "Do you want to download the report?",
                    action: {
                        
                        openInSafari()
                        
                    }
                )
                
            }.sheet(isPresented: $isShowingPDF) {
                PDFPreview(fileURL: fileURL)
                    .presentationDetents([.medium])
            }
    }
    
    func openInSafari(){
        
        if let url = URL(string: ApiClient.shared.baseUrl + "report/generate_report") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        
    }
    
    private func downloadPDF() {
        guard let url = URL(string: ApiClient.shared.baseUrl + "report/generate_report") else {
            return
        }
        
        isDownloading = true
        progress = 0.0
        
        let request = URLRequest(url: url)
        
        let downloadTask = URLSession.shared.downloadTask(with: request) { (url, _, error) in
            defer {
                isDownloading = false
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            do {
                
                guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                    print("Downloads directory not found.")
                    return
                }
                
                // Create the directory if it doesn't exist
                if !FileManager.default.fileExists(atPath: downloadsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error creating Downloads directory: \(error.localizedDescription)")
                        return
                    }
                }
                
                
                // First, check if the file already exists in the "Documents" directory
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    do {
                        // If it exists, delete the existing file
                        try FileManager.default.removeItem(at: self.fileURL)
                        print("Existing file removed.")
                    } catch {
                        print("Error removing existing file: \(error.localizedDescription)")
                    }
                }
                
                if let remoteURL = url {
                    try FileManager.default.moveItem(at: remoteURL, to: self.fileURL)
                    
                    DispatchQueue.main.async {
                        // File is successfully moved, you can notify the user if needed
                        print("File moved to Downloads folder: \(self.fileURL.path)")
                        
                        // Now, you can show the PDF or any other relevant action
                        self.isShowingPDF = true
                    }
                } else {
                    print("Remote URL is nil.")
                }
                
                
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }
    
    
    
    
    
}


struct PDFPreview: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let fileURL: URL
        
        init(_ fileURL: URL) {
            self.fileURL = fileURL
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return fileURL as QLPreviewItem
        }
    }
}

struct UserReportView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportView()
    }
}
