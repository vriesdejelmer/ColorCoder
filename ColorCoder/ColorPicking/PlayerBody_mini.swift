//
//  PlayerBody.swift
//  PsychoPong
//
//  Created by Jelmer de Vries on 02/09/2021.
//  Copyright © 2021 Jelmer de Vries. All rights reserved.
//

import UIKit
import SpriteKit

//protocol PlayerBody {
//    func getPaddlePath(for paddleSize: CGSize) -> UIBezierPath
//}

protocol Paddle: class {
    var shapePath: UIBezierPath { get }
    var targetPosition: CGPoint? { get set }
    func getPaddleBody(with paddleSize: CGSize) -> SKPhysicsBody
}
    
extension Paddle {

    func getPaddleBody(with paddleSize: CGSize) -> SKPhysicsBody {
        let paddleBody  = SKPhysicsBody(edgeLoopFrom: self.shapePath.cgPath)
        paddleBody.affectedByGravity     = false
        paddleBody.restitution           = 1
        paddleBody.friction              = 0
        paddleBody.isDynamic             = false
        return paddleBody
    }

}

class SoapPaddle: SKSpriteNode, Paddle { //, PlayerBody
    
    var shapePath: UIBezierPath
    var targetPosition: CGPoint?
    
    init(paddleSize: CGSize) {
        self.shapePath = getRoundedRectPath(for: paddleSize, roundingFactor: 2)
        let textureImg = UIImage(named: "soap")?.getCustomShape(for: paddleSize, with: self.shapePath)
        super.init(texture: SKTexture(image: textureImg!), color: .green, size: paddleSize)
        
        self.physicsBody   = self.getPaddleBody(with: paddleSize)
    }
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

class RegularPaddle: SKShapeNode, Paddle { //, PlayerBody
    
    var shapePath: UIBezierPath
    var targetPosition: CGPoint?
    
    init(paddleSize: CGSize, color: UIColor) {
        self.shapePath = getRoundedRectPath(for: paddleSize, roundingFactor: 2)
        super.init()
        self.fillColor = color
        self.strokeColor = color
        self.path = shapePath.cgPath
        
//        self.shapePath = getRoundedRectPath(for: paddleSize, roundingFactor: 2)
//        let textureImg = UIImage(named: "")?.getCustomShape(for: paddleSize, with: self.shapePath)
//        super.init(texture: SKTexture(image: textureImg!), color: .green, size: paddleSize)
//
        self.physicsBody   = self.getPaddleBody(with: paddleSize)
    }
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}


func getRoundedRectPath(for size: CGSize, roundingFactor: CGFloat) -> UIBezierPath {
    let centeredRect = centerRectOnPoint(CGRect(origin: .zero, size: size), center: .zero)
    return UIBezierPath(roundedRect: centeredRect, cornerRadius: size.height/roundingFactor)
}
    
//    func getPaddlePath(for paddleSize: CGSize) -> UIBezierPath {
//        let paddleRect = centerRectOnPoint(CGRect(origin: .zero, size: paddleSize), center: .zero)
//        let path = CGMutablePath()
//        path.move(to: paddleRect.origin)
//        path.addLine(to: paddleRect.center)
//        path.addLine(to: CGPoint(x: paddleRect.maxX, y: paddleRect.minY))
//        path.addLine(to: CGPoint(x: paddleRect.maxX, y: paddleRect.maxY))
//        path.addLine(to: paddleRect.center)
//        path.addLine(to: CGPoint(x: paddleRect.minX, y: paddleRect.maxY))
//        path.addLine(to: paddleRect.origin)
//        return UIBezierPath(cgPath: path)
//    }
    
//    func getRoundedRect(for textureImg: UIImage?, of size: CGSize, with cornerRadius: CGFloat) -> UIImage? {
//        let rect    = CGRect(origin: .zero, size: size)
//        let clippingPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
//        return textureImg?.getCustomShape(for: size, with: clippingPath)
//    }
//
//    func getWeirdShape(for textureImg: UIImage?, of size: CGSize, with cornerRadius: CGFloat) -> UIImage? {
//
//        let paddleRect = CGRect(origin: .zero, size: size)
//        let path = CGMutablePath()
//        path.move(to: .zero)
//        path.addLine(to: paddleRect.center)
//        path.addLine(to: CGPoint(x: paddleRect.maxX, y: paddleRect.minY))
//        path.addLine(to: CGPoint(x: paddleRect.maxX, y: paddleRect.maxY))
//        path.addLine(to: paddleRect.center)
//        path.addLine(to: CGPoint(x: paddleRect.minX, y: paddleRect.maxY))
//        path.addLine(to: paddleRect.origin)
//
//        let clippingPath = UIBezierPath(cgPath: path)
//        return textureImg?.getCustomShape(for: size, with: clippingPath)
//    }
//
//    func getDisk(for textureImg: UIImage?, of size: CGSize) -> UIImage? {
//        let rect    = CGRect(origin: .zero, size: size)
//        let clippingPath = UIBezierPath(ovalIn: rect)
//
//        return textureImg?.getCustomShape(for: size, with: clippingPath)
//    }


class Ball: SKShapeNode {
    
    convenience init(of size: CGSize) {
        self.init(ellipseOf: size)
        
        let ballBody                = SKPhysicsBody(circleOfRadius: 10)
        ballBody.friction           = 0
        ballBody.restitution        = 1
        ballBody.linearDamping      = 0
        ballBody.affectedByGravity  = false
        self.physicsBody       = ballBody
    }

}
