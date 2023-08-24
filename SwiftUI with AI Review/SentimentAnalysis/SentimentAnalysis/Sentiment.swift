//
//  Sentiment.swift
//  SentimentAnalysis
//
//  Created by a mystic on 2023/08/24.
//

import SwiftUI
import NaturalLanguage

extension String {
    func predictSentiment(with model: NLModel) -> Sentiment {
        if self.isEmpty { return .neutral }
        let classify = model.predictedLabel(for: self) ?? ""
        print(classify)
        return Sentiment(rawValue: classify)!
    }
}

enum Sentiment: String, CustomStringConvertible {
    case positive = "Pos"
    case negative = "Neg"
    case neutral = "None"

    var description: String { return self.rawValue }

    var emoji: String {
        switch self {
        case .positive: return "😀"
        case .negative: return "☹️"
        default: return "😐"
        }
    }

    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        default: return .gray
        }
    }
}
