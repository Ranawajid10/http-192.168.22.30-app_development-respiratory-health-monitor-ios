//
//  MyProfileView.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 23/08/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct MyProfileView: View {
    
    
    
    @ObservedObject var myProfileVM = MyProfileVM()
    @State private var toast: FancyToast? = nil
    
    
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack {
                    
                    if(myProfileVM.selectedImage==nil && myProfileVM.userImageUrl.isEmpty){
                        
                        ZStack{
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 60,height: 60)
                                .cornerRadius(60)
                            
                        }
                            .frame(width: 100,height: 100)
                            .background(Color.appColorBlue)
                            .cornerRadius(60)
                        
                    }else if let image = myProfileVM.selectedImage {
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100,height: 100)
                            .cornerRadius(60)
                        
                    }else if(!myProfileVM.userImageUrl.isEmpty){
                        
                        WebImage(url: URL(string: myProfileVM.userImageUrl))
                            .resizable()
                            .indicator(.activity)
                            .frame(width: 100,height: 100)
                            .cornerRadius(60)
                        
                    }
                    
                    
                    Button {
                        
                        if(myProfileVM.isEditAble){
                            
                            //
                            myProfileVM.showChoseSheet.toggle()
                            
                        }else{
                            
                            myProfileVM.isError = true
                            myProfileVM.errorMessage = "Please click edit first"
                            
                        }
                        
                    } label: {
                        
                        ZStack{
                            
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 18,height: 14)
                                .foregroundColor(.black)
                            
                        }.frame(width: 32,height: 32)
                            .background(Color.white)
                            .cornerRadius(16)
                    }.padding(.top,-33)
                        .padding(.leading,60)
                    
                    Group{
                        
                        HStack{
                            
                            Text("Full name")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Full Name", text: $myProfileVM.userData.name)
                            .padding(.top,2)
                            .disabled(!myProfileVM.isEditAble)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    Group{
                        HStack{
                            
                            Text("Email Address")
                                .foregroundColor(.gray)
                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        TextField("Enter email", text: $myProfileVM.userData.email)
                            .padding(.top,2)
                            .disabled(true)
                        
                        Color.gray
                            .frame(height: 1)
                        
                    }
                    
                    //                    Group{
                    //                        HStack{
                    //
                    //                            Text("Password")
                    //                                .foregroundColor(.gray)
                    //                                .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                    //
                    //                            Spacer()
                    //
                    //                        }.padding(.top)
                    //
                    //                        HStack{
                    //
                    //                            TextField("Enter password", text: $password)
                    //                                .padding(.top,2)
                    //                                .disabled(!isEditAble)
                    //
                    //                            NavigationLink {
                    //
                    //                                ChangePasswordView()
                    //
                    //                            } label: {
                    //
                    //                                Text("Change")
                    //                                    .foregroundColor(.appColorBlue)
                    //                                    .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 14))
                    //                                    .underline()
                    //
                    //                            }
                    //
                    //
                    //                        }
                    //
                    //                        Color.gray
                    //                            .frame(height: 1)
                    //
                    //
                    //                    }
                    
                    
                    Button {
                        
                        if(myProfileVM.isEditAble){
                            
                            myProfileVM.updateProfile()
                            
                        }else{
                            
                            withAnimation {
                                
                                myProfileVM.isEditAble.toggle()
                                
                            }
                            
                        }
                        
                    } label: {
                        
                        
                        Text(myProfileVM.isEditAble == true ? "Save" : "Edit" )
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width-60,height: 42)
                            .background(Color.appColorBlue)
                            .cornerRadius(40)
                        
                    }.padding(.top)
                    
                }.padding(.horizontal)
            }
            
            if(myProfileVM.isLoading){
                
                LoadingView()
                
            }
            
        }.toastView(toast: $toast)
            .background(Color.screenBG)
            .onChange(of: myProfileVM.isError){ newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .error, title: "Error occurred!", message: myProfileVM.errorMessage)
                    myProfileVM.isError = false
                }
                
            }
            .sheet(isPresented: $myProfileVM.showChoseSheet) {
                
                ChoseImageSheet(showChoseSheet: $myProfileVM.showChoseSheet, selectedImage: $myProfileVM.selectedImage)
                    .presentationDetents([.height(100)])
                    .presentationCornerRadius(35)
                
            }
            .onChange(of: myProfileVM.isUpdated){ newValue in
                
                if(newValue){
                    
                    toast = FancyToast(type: .success, title: "Updated", message: "Profile updated successfully")
                    myProfileVM.isUpdated = false
                    myProfileVM.isEditAble = false
                    
                }
                
            }
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
    }
}


struct ChoseImageSheet:View{
    
    @Binding var showChoseSheet:Bool
    @Binding var selectedImage:UIImage?
    @Environment(\.presentationMode) var presentationMode
    @State private var imagePickerSourceType: UIImagePickerController.SourceType? = nil
    @State  var showSheet = false
    
    
    
    var body: some View{
        
        VStack{
            
            Color.black
                .frame(width: 40,height: 3)
                .cornerRadius(2)
            
            
            
            HStack(spacing: 50){
                
                Spacer()
                
                Button {
                    
                    showSheet = true
                    self.imagePickerSourceType = .camera
                    
                } label: {
                    
                    VStack{
                        
                        Image(systemName: "camera.aperture")
                            .resizable()
                            .frame(width: 35,height: 35)
                            .foregroundColor(Color.appColorBlue)
                        
                        
                        Text("Camera")
                            .foregroundColor(Color.black)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        
                    }
                    
                }
                
                Button {
                    
                    showSheet = true
                    self.imagePickerSourceType = .photoLibrary
                    
                } label: {
                    
                    VStack{
                        
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 35,height: 30)
                            .foregroundColor(Color.appColorBlue)
                        
                        Text("Gallery")
                            .foregroundColor(Color.black)
                            .modifier(LatoFontModifier(fontWeight: .regular, fontSize: 16))
                        
                    }
                    
                    
                }
                
                
                
                Spacer()
                
            }
            
            
            
            Spacer()
            
        }.padding(.top)
            .padding(.horizontal)
            .background(Color.screenBG)
            .sheet(isPresented: $showSheet){
                ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSourceType!)
                    .onDisappear{
                        
                        showChoseSheet.toggle()
                        
                    }
            }
        
        
        
    }
    
    
    
    
    
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            } else {
                parent.selectedImage = nil
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.selectedImage = nil
            picker.dismiss(animated: true)
        }
    }
}
