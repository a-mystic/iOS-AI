//
//  Extensions.swift
//  DrawingDetector
//
//  Created by mystic on 2022/10/11.
//

import UIKit

extension CGContext {
    static func create(size: CGSize, action: (inout CGContext) -> ()) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard var context = UIGraphicsGetCurrentContext() else { return nil }
        action(&context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}


