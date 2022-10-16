//
//  ContentView.swift
//  StyleTransfer
//
//  Created by mystic on 2022/10/13.
//

import SwiftUI

struct ContentView: View {
    @State private var imagePickerOn = false
    @State private var selectedImage: UIImage?
    @State var selectedStyle = StyleModel(index: 0)
    
    private let blankImage = Image(systemName: "photo")
    private var ClassifyEnable: Bool { selectedImage != nil }
    private var modelSelection: StyleModel { return StyleModel(index: selectedStyle.styleIndex) }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ImageView
                Spacer()
                PickerView
                Text("Choose:\(modelSelection.name)")
                Spacer()
                TransferButton
            }
            .sheet(isPresented: $imagePickerOn) {
                ImagePickerView { image in
                    if let image = image {
                        selectedImage = image
                    }
                }
            }
            .padding()
            .navigationTitle(Text("StyleTransfer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        imagePickerOn = true
                    } label: {
                        Image(systemName: "photo")
                    }
                }
                ToolbarItem {
                    Button {
                        share()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var ImageView: some View {
        if selectedImage != nil {
            Image(uiImage: selectedImage!).resizable().aspectRatio(contentMode: .fit)
        } else {
            blankImage.font(.largeTitle).aspectRatio(contentMode: .fit)
        }
    }
    
    private var TransferButton: some View {
        Button {
            StyleTransfer()
        } label: {
            Text("StyleTransfer").padding(.horizontal,50).font(.title).foregroundColor(.black).background(.white).cornerRadius(20)
        }.disabled(!ClassifyEnable)
    }
    
    private var PickerView: some View {
        Picker("Style models", selection: $selectedStyle) { // must equal type foreach items, selection
            ForEach(StyleModel.allCases, id: \.self) { style in
                Text(style.name)
            }
        }.pickerStyle(.wheel)
    }
    
    private func StyleTransfer() {
        selectedImage = selectedImage?.styled(with: modelSelection)
        if selectedImage == nil {
            print("\(#function) error")
        }
    }
    
    private func share() {
        
    }
}
