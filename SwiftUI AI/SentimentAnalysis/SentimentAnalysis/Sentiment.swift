//
//  Sentiment.swift
//  SentimentAnalysis
//
//  Created by mystic on 2022/10/09.
//

import UIKit
import SwiftUI
import NaturalLanguage

extension String {
    func predictSentiment(with nlModel: NLModel?) -> Sentiment {
        if self.isEmpty { return .neutral }
        guard let nlModel = nlModel else { return Sentiment(rawValue: "")}
        let classString = nlModel.predictedLabel(for: self) ?? ""
        return Sentiment(rawValue: classString)
    }
}

enum Sentiment: String, CustomStringConvertible {
    case positive = "Positive"
    case negative = "Negative"
    case neutral = "None"
    
    init(rawValue: String) {
        switch rawValue {
        case "Pos": self = .positive
        case "Neg": self = .negative
        default: self = .neutral
        }
    }
    
    var description: String { return self.rawValue }
    var icon: String {
        switch self {
        case .positive: return "😄"
        case .negative: return "😡"
        default: return "😐"
        }
    }
    var color: Color {
        switch self {
        case .positive: return Color.orange
        case .negative: return Color.red
        default: return Color.gray
        }
    }
}
