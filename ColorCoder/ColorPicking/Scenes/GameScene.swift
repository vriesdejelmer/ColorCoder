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
    weak var displayDelegate: DisplayDelegate?
    var colorChoices = [ColorClickNode]()
    var ordering: NodeOrdering { return .leftToRight }
    
    var leftRotation: Bool = true
    
    var centerNode: ColorControlNode!
    
    var orientation: OrientationDirection   = .horizontal
    var setupCompleted   = false

        //Sizing
    var stimulusDiameter: CGFloat = GeneralSettings.nodeDiameter
    let controlDiameter: CGFloat = GeneralSettings.DefaultParams.centerRingDiameter
    var centerDistance: CGFloat = GeneralSettings.nodeEccentricity
    var lineWidth: CGFloat = GeneralSettings.DefaultParams.centerRingWidth
    
        //Node specifics
    let numberOfNodes: Int = GeneralSettings.DefaultParams.numberOfNodes
    var nodeSteps: Int { return GeneralSettings.DefaultParams.nodeSteps }
    var targetHueSteps: Int { return GeneralSettings.DefaultParams.targetSteps }
    
    let shuffleTime = 0.15
    
        //Trial caching
    var nextTargetStep: Int!
    var startIndex: Int = 0
    var nodeOrdering: [Int]!
    var nextNodeStep: Int!
    
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
        
        self.colorTarget = ColorClickNode.init(ellipseOf: CGSize(width: stimulusDiameter, height: stimulusDiameter))
        if let colorTarget = self.colorTarget as? ColorClickNode {
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
            centerNode.lineWidth = lineWidth
            self.addChild(centerNode)
            self.centerControlNode()
        }
    }
    
    func getMidPoint() -> CGPoint {
        if self.orientation == .vertical {
            return CGPoint(x: self.frame.center.x, y: self.frame.center.y*1.05)
        } else {
            return CGPoint(x: self.frame.center.x, y: self.frame.center.y*0.95)
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        
        self.setOrientation(to: self.frame.size)
        self.centerControlNode()
        if self.setupCompleted && self.nextNodeStep != nil { self.positionAndColorNodes(shuffle: false) }
    }

    func setOrientation(to size: CGSize) {
        if size.width > size.height {
            self.orientation = .horizontal
        } else {
            self.orientation = .vertical
        }
    }
    
    func setNextTrialParameters() {
        
        self.nodeOrdering = self.getNextNodeOrdering()
       
        self.nextNodeStep = Int.random(in: 0..<self.nodeSteps)
        self.nextTargetStep = Int.random(in: 0..<self.targetHueSteps)
    }
    
    func getNextNodeOrdering() -> [Int] {
        if self.ordering == .leftToRight {
            self.startIndex += Int(ceil(Double(self.numberOfNodes)/2))
            return Array(self.startIndex...(self.startIndex+self.numberOfNodes-1)).map { $0 % self.numberOfNodes }
        } else {
            var newOrdering = Array(0..<self.numberOfNodes).shuffled()
            while newOrdering == self.nodeOrdering {
                newOrdering = Array(0..<self.numberOfNodes).shuffled()
            }
            return newOrdering
        }
    }
    
    func centerControlNode() {
        let midPoint = self.getMidPoint()
        self.centerNode?.position = midPoint
    }
    
    func getRotationOffset() -> CGFloat {
        let rotationOffset: CGFloat
        if leftRotation { rotationOffset = -(1/CGFloat(self.numberOfNodes-1))/4 }
        else { rotationOffset = (1/CGFloat(self.numberOfNodes-1))/4 }
        leftRotation = !leftRotation
        return rotationOffset
    }
    
    func positionAndColorNodes(shuffle: Bool = true) {
        
        let rotationOffset = self.getRotationOffset()
        
        for (index, nodeIndex) in self.nodeOrdering.enumerated() {
            let node = colorChoices[nodeIndex]
            node.hue = CGFloat(nodeIndex*self.nodeSteps + self.nextNodeStep)/CGFloat(self.numberOfNodes*self.nodeSteps)
            
            let rad = -((CGFloat(index)/CGFloat(self.numberOfNodes-1)+rotationOffset) * CGFloat.pi) - CGFloat.pi
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
        self.exitDelegate?.closeSession()
    }
    
    func startTrial() {
        self.centerNode.strokeColor = hsv_to_rgb(h: CGFloat(self.nextTargetStep)/CGFloat(self.targetHueSteps), s: 1.0, v: 1.0)
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

public enum NodeOrdering: String, Codable {
    case shuffled = "RND", leftToRight = "LTR"
}

public enum ScreenOrientation: String, Codable {
    case vertical = "VER", horizontal = "HOR"
    
    var longName: String {
        switch self {
        case .vertical: return "PORTRAIT"
        case .horizontal: return "LANDSCAPE"
        }
        
    }
}
