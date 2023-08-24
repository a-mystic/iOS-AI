//
//  ContentView.swift
//  SentimentAnalysis
//
//  Created by a mystic on 2023/08/24.
//

import SwiftUI
import NaturalLanguage
import CoreML

struct ContentView: View {
    private var model: NLModel? {
        let config = MLModelConfiguration()
        return try? NLModel(mlModel: SentimentClassificationModel(configuration: config).model)
    }
    
    var body: some View {
        VStack {
            status
            input
            analyse
        }
        .padding()
    }
    
    @State private var emojiStatus = "😐"
    @State private var colorStatus = Color.gray
    @State private var emotionStatus = "None"
    
    var status: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(colorStatus)
            VStack {
                Text(emojiStatus)
                    .font(.system(size: 128))
                Text(emotionStatus)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }
        }
    }
    
    @State private var inputText = ""
    
    var input: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $inputText) // <= Here
                .padding(4)
            if inputText.isEmpty {
                Text("Input here")
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }
        }
        .font(.body)
    }
    
    var analyse: some View {
        Button {
            analyseSentiment()
        } label: {
            Text("Analyse Sentiment")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @State private var sentimentClass = Sentiment.neutral
    
    private func analyseSentiment() {
        if let nlModel = self.model {
            sentimentClass = inputText.predictSentiment(with: nlModel)
        }
        emojiStatus = sentimentClass.emoji
        emotionStatus = sentimentClass.description
        colorStatus = sentimentClass.color 
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
