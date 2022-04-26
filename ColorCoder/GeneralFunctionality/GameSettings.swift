//
//  GameSettings.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

struct GameSettings {
    static let paddleThickness: CGFloat     = 80
    static let paddleWidth: CGFloat         = 200
    static var paddleSize                   = CGSize(width: paddleWidth, height: paddleThickness)
    static var paddleCornerRadius: CGFloat  = paddleThickness*2
    static let ballSize                     = CGSize(width: 20, height: 20)
    static let paddleSideOffset: CGFloat    = 100
    static let maxSpeed: CGFloat            = 12
    static let minSpeed: CGFloat            = 2
//    static var directionalSpeed: CGVector {
//        let range = maxSpeed - minSpeed
//        let directionalSpeed = range*GeneralSettings.ballSpeed + minSpeed
//        return CGVector(dx: directionalSpeed, dy: directionalSpeed)
//    }
//    static func getReversedIntensity(for orientation: OrientationDirection) -> CGVector {
//        //var directionalIntensity = self.directionalSpeed
//        if orientation == .vertical {
//            directionalIntensity.dy = -directionalIntensity.dy
//        } else {
//            directionalIntensity.dx = -directionalIntensity.dx
//        }
//        return directionalIntensity
//    }
    static var invertedPaddleSize: CGSize   = CGSize(width: paddleThickness, height: paddleWidth)
}
