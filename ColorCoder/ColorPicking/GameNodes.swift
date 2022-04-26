//
//  GameNodes.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 25/04/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import SpriteKit


class ColorClickNode: SKShapeNode {
    
    private var radPosition: CGFloat = 0
    public var isGoodNode: Bool!
    weak public var choiceDelegate: ChoiceDelegate?
    var hueIndex = -1
    
    var hue: CGFloat! {
        didSet {
            let nodeColor = hsv_to_rgb(h: hue, s: 1.0, v: 1.0)
            self.strokeColor = nodeColor
            self.fillColor = nodeColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.choiceDelegate?.selected(hueIndex)
    }
    
    func logRadPosition(_ rad: CGFloat) {
        self.radPosition = rad
    }
    
    func getRadPosition() -> CGFloat {
        return self.radPosition
    }
}



class ColorControlNode: SKShapeNode {
    

    weak var gameDelegate: GameDelegate?
    
    let shrinkAction: SKAction = {
        return SKAction.scale(to: 0, duration: 0.15)
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.run(shrinkAction) {
            self.gameDelegate?.startTrial()
            self.setScale(1.0)
            
        }

    }
}
