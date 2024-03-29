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
    override var ordering: NodeOrdering { return experimentData.nodeOrdering }
    
    override var nodeSteps: Int {
        return experimentData.nodeSteps
    }
    override var targetHueSteps: Int {
        return experimentData.targetSteps
    }
    
    
    var experimentData: ExperimentData! {
        didSet {
            self.stimulusDiameter = experimentData.stimulusDiameter
            self.centerDistance = experimentData.centerDistance
            self.experimentData.addSessionStart(CFAbsoluteTimeGetCurrent())
        }
    }
    
    override var centerColor: UIColor {
        return UIColor(white: (experimentData.backgroundShade + 0.5).remainder(dividingBy: 1.0), alpha: 1.0)
    }
    
        // timing
    var trialSetupTime: TimeInterval?
    var trialStartTime: TimeInterval?
    var trialTime: TimeInterval?
    var initiationTime: TimeInterval?

    override func didMove(to view: SKView) {
        view.showsPhysics   = false
        
        super.didMove(to: view)
        
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
    
    override func setupNextTrial() {
        self.trialSetupTime = CFAbsoluteTimeGetCurrent()
        super.setupNextTrial()
    }

    func logTimes() {
        if let startTime = self.trialStartTime {
            self.trialTime = CFAbsoluteTimeGetCurrent() - startTime
            if let setupTime = self.trialSetupTime {
                self.initiationTime = startTime - setupTime
            }
        }
    }

    override func selected(_ selectedIndex: Int) {

        self.logTimes()
        
        self.experimentData.addTrial(number: trialCounter, targetOffset: self.nextTargetStep, nodeOffset: self.nextNodeStep, trialTime: self.trialTime ?? 0.0, preTrialTime: self.initiationTime ?? 0.0, response: selectedIndex, leftRotation: self.leftRotation, ordering: self.nodeOrdering)

        if self.experimentData.hasTrialsLeft {
            if (self.trialCounter+1) % GeneralSettings.DefaultParams.progressTrials == 0 {
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
    func createUserProfile(for expInfo: [ExperimentParameter: String]) -> UserProfile?
    func hasUnfinishedVersions(for userInitials: String) -> ExperimentData?
    func nextVersion(for userInitials: String) -> Int
}


protocol DisplayDelegate: AnyObject {
    func displayProgress(trialNumber: Int, trialsLeft: Int)
    func updateTrialCount(to score: Int)
    func showInstructions()
}
