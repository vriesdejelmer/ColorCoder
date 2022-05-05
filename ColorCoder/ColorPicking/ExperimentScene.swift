//
//  GameScene.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import SpriteKit

class ExperimentScene: GameScene {

    weak var dataDelegate: DataDelegate?
    
        //trials
    var trialCounter = 0
    var trialResponses: [Int]!
    
    var experimentData: ExperimentData!
    
        // timing
    var trialTime: TimeInterval?
    var trialStartTime: TimeInterval?

    override func didMove(to view: SKView) {
        view.showsPhysics   = false
        
        super.didMove(to: view)
        
        self.displayDelegate?.showInstructions()
    }

    override func setNextTrialParameters() {
        super.setNextTrialParameters()
        
        if self.trialCounter == 0, let trialParam = self.experimentData.trialParam {
            self.nextNodeStep = trialParam.nodeStep
            self.nextTargetStep = trialParam.targetStep
        } else if let trialParam = self.experimentData.getNextTrialParameters() {
            self.nextNodeStep = trialParam.nodeStep
            self.nextTargetStep = trialParam.targetStep
        }
        
    }


    override func selected(_ selectedIndex: Int) {

        if let startTime = self.trialStartTime {
            self.trialTime = CFAbsoluteTimeGetCurrent() - startTime
        }
        
        self.experimentData.addTrial(number: trialCounter, targetOffset: self.nextTargetStep, nodeOffset: self.nextNodeStep, trialTime: self.trialTime!, response: selectedIndex)

        if self.experimentData.hasTrialsLeft {
            if (self.trialCounter+1) % 5 == 0 {
                self.displayDelegate?.displayProgress(trialNumber: self.trialCounter+1, trialsLeft: self.experimentData.trialsLeft)
            }
            
            self.trialCounter += 1
            super.selected(selectedIndex)
            self.positionAndColorNodes(shuffle: true)
            
            
            if (self.trialCounter % 10 == 0) {
                self.dataDelegate?.saveProgress(experimentData)
            }
        } else {
            self.closeSession()
        }
        
       
    }
    
    override func startTrial() {
        super.startTrial()
        self.trialStartTime = CFAbsoluteTimeGetCurrent()
        
    }
    
    override func closeSession() {
           
            //Clear the scene, necesarry?
        for node in self.children {
            node.removeFromParent()
        }
        
        self.dataDelegate?.saveProgress(experimentData)
        self.exitDelegate?.closeSession()
    }
    
}


protocol DataDelegate: AnyObject {
    func saveProgress(_ experimentData: ExperimentData)
    func isExistingUser(_ initials: String) -> Bool
}


protocol DisplayDelegate: AnyObject {
    func displayProgress(trialNumber: Int, trialsLeft: Int)
    func updateTrialCount(to score: Int)
    func showInstructions()
}
