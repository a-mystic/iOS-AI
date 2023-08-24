import Cocoa

class MarkovChain {
    private let startWords: [String]
    private let links: [String: [Link]]
    private(set) var sequence: [String] = []
    
    init?(with inputFilepath: String) {
        guard let filePath = Bundle.main.path(forResource: inputFilepath, ofType: ".txt"),
              let inputFile = FileManager.default.contents(atPath: filePath),
              let inputString = String(data: inputFile, encoding: .utf8) else { return nil }
        let tokens = inputString.tokenize()
        var startWords: [String] = []
        var links: [String: [Link]] = [:]
        
        for index in 0..<tokens.count - 1 {
            let thisToken = tokens[index]
            let nextToken = tokens[index + 1]
            if thisToken == String.sentenceEnd {
                startWords.append(nextToken)
                continue
            }
            var tokenLinks = links[thisToken, default: []]
            if nextToken == String.sentenceEnd {
                if !tokenLinks.contains(.end) {
                    tokenLinks.append(.end)
                }
                links[thisToken] = tokenLinks
                continue
            }
            let wordLinkIndex = tokenLinks.firstIndex { element in
                if case .word = element { return true }
                return false
            }
            var options: [String] = []
            if let index = wordLinkIndex {
                options = tokenLinks[index].words
                tokenLinks.remove(at: index)
            }
            options.append(nextToken)
            tokenLinks.append(.word(options: options))
            links[thisToken] = tokenLinks
        }
        
        self.links = links
        self.startWords = startWords
        if startWords.isEmpty { return nil }
    }
    
    func clear() {
        self.sequence = []
    }
    
    func nextWord() -> String {
        let newWord: String
        if self.sequence.isEmpty || self.sequence.last == String.sentenceEnd {
            newWord = startWords.randomElement()!
        } else {
            let lastWord = self.sequence.last!
            let link = links[lastWord]?.randomElement()
            newWord = link?.words.randomElement() ?? "."
        }
        self.sequence.append(newWord)
        return newWord
    }
    
    func generate(wordCount: Int = 100) -> String {
        for _ in 0..<wordCount {
            let _ = self.nextWord()
        }
        return self.sequence.joined(separator: "").replacingOccurrences(of: " .", with: ".") + "..."
    }
    
    enum Link: Equatable {
        case end, word(options: [String])
        
        var words: [String] {
            switch self {
            case .end: return []
            case .word(let words): return words
            }
        }
    }
}

let file = "wonderland"
if let markovChain = MarkovChain(with: file) {
    print(markovChain.generate())
} else {
    print("fail")
}

