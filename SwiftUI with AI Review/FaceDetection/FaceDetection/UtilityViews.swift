//
//  UtilityViews.swift
//  FaceDetection
//
//  Created by a mystic on 2023/08/24.
//

import SwiftUI

struct TwoStateButton: View {
    private let text: String
    private let disabled: Bool
    private let background: Color
    private let action: () -> Void
    
    init(text: String, disabled: Bool, background: Color = .blue, action: @escaping () -> Void) {
        self.text = text
        self.disabled = disabled
        self.background = disabled ? .gray : background
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(text).font(.title).bold().foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(background)
            .cornerRadius(10)
        }
        .disabled(disabled)
    }
}

struct MainView: View {
    var image: UIImage
    var text: String
    var button: TwoStateButton
    
    var body: some View {
        VStack {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
            Spacer()
            Text(text).font(.title).bold()
            Spacer()
            button
        }
    }
}
