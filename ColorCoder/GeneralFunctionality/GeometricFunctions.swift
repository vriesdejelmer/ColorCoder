//
//  GeometricFunctions.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

public func centerRectOnPoint(_ rect: CGRect, center: CGPoint) -> CGRect {
    let offsetX = rect.midX - center.x
    let offsetY = rect.midY - center.y
    var newRect = rect
    newRect.origin.x -= offsetX
    newRect.origin.y -= offsetY
    
    
    return newRect
}
