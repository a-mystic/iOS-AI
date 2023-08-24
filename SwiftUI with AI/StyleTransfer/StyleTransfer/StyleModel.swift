//
//  StyleModel.swift
//  StyleTransfer
//
//  Created by mystic on 2022/10/13.
//

import UIKit
import CoreML

enum StyleModel: String, CaseIterable {
    case abstract = "Abstract"
    case apples = "Apples"
    case brick = "Brick"
    case flower = "Flower"
    case foliage = "Foliage"
    case honeycomb = "Honeycomb"
    case mosaic = "Mosaic"
    case nebula = "Nebula"
    
    var model: StyleTransferModel { return StyleTransferModel() }
    var constraints: CGSize { return CGSize(width: 800, height: 800) }
    var styleArray: MLMultiArray { return MLMultiArray(size: StyleModel.allCases.count, selecting: self.styleIndex) }

    init(index: Int) {
        self = StyleModel.styles[index]
    }
    
    static var styles: [StyleModel] { return self.allCases.filter { $0.isActive }}
    var isActive: Bool { return true }
    var name: String { return self.rawValue }
    var styleIndex: Int { return StyleModel.styles.firstIndex(of: self)! }
}
