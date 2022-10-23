//
//  Models.swift
//  GAN
//
//  Created by mystic on 2022/10/23.
//

import CoreML
import UIKit

public protocol ImageGenerator {
    func prediction() -> UIImage?
}

extension MnistGan: ImageGenerator {
    convenience init(modelName: String) {
        let bundle = Bundle(for: MnistGan.self)
        let url = bundle.url(forResource: modelName, withExtension: "mlmodelc")!
        try! self.init(contentsOf: url)
    }
    
    func prediction() -> UIImage? {
        if let noiseArray = MLMultiArray.getRandomNoise(), let output = try? self.prediction(input: MnistGanInput(input1: noiseArray)) {
            return UIImage(data: output.output1)
        }
        return nil
    }
}
