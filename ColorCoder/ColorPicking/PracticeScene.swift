//
//  GameScene.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import SpriteKit


protocol CoderViewContainer: AnyObject {
    func updateTrialCount(to score: Int)
}

class PracticeScene: GameScene {

    weak var viewDelegate: CoderViewContainer?

        //trials
    let numberOfTrials = 1000
    var trialCounter = 0 {
        didSet { self.viewDelegate?.updateTrialCount(to: trialCounter) }
    }
        
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.showsPhysics   = true
        
    }
        
    override func selected(_ selectedIndex: Int) {
        if self.trialCounter >= self.numberOfTrials {
            self.closeSession()
        } else {
            super.selected(selectedIndex)
            self.positionAndColorNodes(shuffle: true)
            self.trialCounter += 1
        }
    }


}

