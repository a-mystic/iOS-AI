//
//  ContentView.swift
//  SentimentAnalysis
//
//  Created by mystic on 2022/10/09.
//

import SwiftUI
import NaturalLanguage

struct ContentView: View {
    @State private var AnalyseEmoji = "😀"
    @State private var AnalysingResult = "None"
    @State private var inputText = ""
    @State private var EmojiBackgroundColor = Color.gray
    
    private var model: NLModel?
    
    init() {
        model = try? NLModel(mlModel: SentimentClassificationModel().model)
    }
    
    var body: some View {
            VStack {
                showAnalysisView
                TextField("Typing something here", text: $inputText).autocorrectionDisabled(false)
                Spacer()
                analyseButton
            }
    }
    
    var showAnalysisView: some View {
        VStack {
            Text(AnalyseEmoji).font(.largeTitle).scaleEffect(4)
            Spacer().frame(height: 50)
            Text(AnalysingResult).font(.title)
        }
        .padding(150)
        .background(EmojiBackgroundColor)
        .cornerRadius(20)
    }
    var analyseButton: some View {
        Button {
            SentimentAnalyse()
        } label: {
            Text("Analyse")
                .padding(.horizontal, 50)
                .font(.title)
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(20)
        }
    }
    
    private func SentimentAnalyse() {
        var sentimentClass = Sentiment.neutral
        sentimentClass = inputText.predictSentiment(with: self.model)
        AnalyseEmoji = sentimentClass.icon
        AnalysingResult = sentimentClass.description
        EmojiBackgroundColor = sentimentClass.color
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
