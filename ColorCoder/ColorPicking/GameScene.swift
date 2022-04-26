//
//  GameScene.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, ChoiceDelegate, GameDelegate {

    var colorTarget: SKNode!
    weak var exitDelegate: ExitDelegate?
    var colorChoices = [ColorClickNode]()
    
    var centerNode: ColorControlNode!
    
    var orientation: OrientationDirection   = .horizontal
    var setupCompleted   = false

        //Sizing
    let targetDiameter: CGFloat = GeneralSettings.nodeSize
    let controlDiameter: CGFloat = 125
    let centerDistance: CGFloat = GeneralSettings.nodeEccentrictiy
    
        //Node specifics
    let numberOfNodes = 7
    let nodeSteps = 20
    let targetHueSteps = 50
    
    let shuffleTime = 0.15
    
        //Trial caching
    var lastIndex: Int?
    var nextTargetIndex: Int!
    var startIndex: Int!
    var nextRandomStep: Int!

    var centerColor: UIColor {
        return UIColor(white: (GeneralSettings.backgroundGray + 0.5).remainder(dividingBy: 1.0), alpha: 1.0)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        if !self.setupCompleted { self.setupScene() }
    }

    func setupScene() {
        self.backgroundColor = GeneralSettings.backgroundColor
        self.initializeNodes()
        self.setupNextTrial()
        self.setupCompleted = true
    }


    func initializeNodes() {
        
        self.colorTarget = ColorClickNode.init(ellipseOf: CGSize(width: targetDiameter, height: targetDiameter))
        if let colorTarget = self.colorTarget as? ColorClickNode {
            colorTarget.lineWidth = 10
            colorTarget.isUserInteractionEnabled = false
        }
        
        for nodeIndex in 0..<self.numberOfNodes {
            if let node = self.colorTarget?.copy() as! ColorClickNode? {
                node.choiceDelegate = self
                node.hueIndex = nodeIndex
                self.addChild(node)
                self.colorChoices.append(node)
                node.isUserInteractionEnabled = false
            }
        }
        
        self.centerNode = ColorControlNode.init(ellipseOf: CGSize(width: controlDiameter, height: controlDiameter))
        
        if let centerNode = self.centerNode {
            centerNode.gameDelegate = self
            centerNode.isUserInteractionEnabled = true
            centerNode.strokeColor = self.centerColor
            centerNode.lineWidth = 25
            self.addChild(centerNode)
            self.centerControlNode()
        }
    }
    
    func getMidPoint() -> CGPoint {
        if self.orientation == .vertical {
            return CGPoint(x: self.frame.center.x, y: self.frame.center.y*0.9)
        } else {
            return CGPoint(x: self.frame.center.x, y: self.frame.center.y*0.8)
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        
        self.setOrientation(to: self.frame.size)
        self.centerControlNode()
        if self.setupCompleted && self.nextRandomStep != nil { self.positionAndColorNodes(shuffle: false) }
    }

    func setOrientation(to size: CGSize) {
        if size.width > size.height {
            self.orientation = .horizontal
        } else {
            self.orientation = .vertical
        }
    }
    
    func setNextTrialParameters() {
        if let previousSelection = self.lastIndex {
            self.startIndex = Int.random(in: 0..<self.numberOfNodes)
            while self.startIndex == previousSelection { startIndex = Int.random(in: 0..<self.numberOfNodes) }
        } else {
            self.startIndex = Int.random(in: 0..<self.numberOfNodes)
        }
        self.lastIndex = startIndex
        
        self.nextRandomStep = Int.random(in: 0..<self.nodeSteps)
        self.nextTargetIndex = Int.random(in: 0..<self.targetHueSteps)
    }
    
    func centerControlNode() {
        let midPoint = self.getMidPoint()
        self.centerNode?.position = midPoint
    }
    
    func positionAndColorNodes(shuffle: Bool = true) {
        
        let nodeIndices: [Int] = Array(self.startIndex...(self.startIndex+self.numberOfNodes-1)).map { $0 % self.numberOfNodes }
        for (index, nodeIndex) in nodeIndices.enumerated() {
            let node = colorChoices[nodeIndex]
            node.hue = CGFloat(nodeIndex*self.nodeSteps + self.nextRandomStep)/CGFloat(self.numberOfNodes*self.nodeSteps)
            let rad = -(CGFloat(index)/CGFloat(self.numberOfNodes-1) * (CGFloat.pi*1.1)) - CGFloat.pi*0.95
            let x = self.getMidPoint().x + cos(rad) * self.centerDistance
            let y = self.getMidPoint().y + sin(rad) * self.centerDistance
            let nodePosition = CGPoint(x: x, y: y)
            
            if shuffle {
                let moveAction = SKAction.move(to: nodePosition, duration: self.shuffleTime)
                node.run(moveAction)
            } else {
                node.position = nodePosition
            }
        }
    }


    func selected(_ selectedIndex: Int) {
        self.setupNextTrial()
    }
    
    func setupNextTrial() {
        self.centerNode.strokeColor = self.centerColor
        self.centerNode.isUserInteractionEnabled = true
        colorChoices.forEach { $0.isUserInteractionEnabled = false }
        self.setNextTrialParameters()
    }
    
    func closeSession() {
        self.exitDelegate?.closeSessions(nil)
    }
    
    func startTrial() {
        self.centerNode.strokeColor = hsv_to_rgb(h: CGFloat(self.nextTargetIndex)/CGFloat(self.targetHueSteps), s: 1.0, v: 1.0)
        colorChoices.forEach { $0.isUserInteractionEnabled = true }
        self.centerNode.isUserInteractionEnabled = false
        
    }
}


protocol GameDelegate: AnyObject {
    func startTrial()
}

protocol ChoiceDelegate: AnyObject {
    func selected(_ selectedIndex: Int)
}