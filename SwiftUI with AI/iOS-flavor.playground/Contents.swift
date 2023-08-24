import NaturalLanguage
import Foundation
import CoreML

extension String {
    func predictLanguage() -> String {
        let locale = Locale(identifier: "en_US")
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        let language = recognizer.dominantLanguage
        return locale.localizedString(forRegionCode: language!.rawValue) ?? "unknown"
    }
    
    func printNamedEntities() {
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
        tagger.string = self
        let range = NSRange(location: 0, length: self.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: range, scheme: .nameType) { tag, tokenRange, stop, _  in
            if let tag = tag, tags.contains(tag) {
                let name = (self as NSString).substring(with: tokenRange)
                print("\(name) is a \(tag.rawValue)")
            }
        }
    }
}

//let text = ["My hovercraft is full of eels",
//            "Mijn hovercraft zit vol palingen",
//            "我的氣墊船充滿了鰻魚",
//            "Mit luftpudefartøj er fyldt med ål",
//            "Το χόβερκραφτ μου είναι γεμάτο χέλια",
//            "제 호버크래프트가 장어로 가득해요",
//            "Mi aerodeslizador está lleno de anguilas",
//            "Mein Luftkissenfahrzeug ist voller Aale"]
//for string in text { print("\(string) is in \(string.predictLanguage())")}

let sentence = "Marina, Jon, and Tim write books for O'Reilly Media " +
    "and live in Tasmania, Australia."
sentence.printNamedEntities()

