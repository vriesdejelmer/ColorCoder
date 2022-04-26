//
//  GameScene.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import SpriteKit

class ExperimentScene: GameScene {

        //trials
    var trialCounter = 0
    var trialResponses: [Int]!
    
    var comboArray: [(Int, Int)]!
    
    var experimentData: ExperimentData!

    override func didMove(to view: SKView) {
        self.comboArray = self.getComboArray()
        print(self.comboArray)
        print(self.comboArray.count)
        self.trialResponses = [Int](repeating: -2, count: self.comboArray.count)
        view.showsPhysics   = false
        
        super.didMove(to: view)
    }
    
    func getComboArray() -> [(Int,Int)] {
        let baseHueArray: [Int] = Array(0..<self.targetHueSteps)
        let nodeArray: [Int] = Array(0..<self.nodeSteps)

        let nodeSelection = Array(nodeArray.map({[Int](repeating: $0, count: baseHueArray.count)}).joined())
        let hueSelection = [Int](repeating: baseHueArray, count: self.nodeSteps)
        
        return Array(zip(nodeSelection, hueSelection))
    }

    override func setNextTrialParameters() {
        super.setNextTrialParameters()
        
        guard let index = comboArray.indices.randomElement() else { return }
        let (randomStep, targetIndex) = comboArray.remove(at: index)
        self.nextRandomStep = randomStep
        self.nextTargetIndex = targetIndex
        print("Next Target \(self.nextTargetIndex)")
        print("Next Random Step \(self.nextRandomStep)")
    }


    override func selected(_ selectedIndex: Int) {
        self.experimentData.addTrial(number: trialCounter, targetHue: self.nextTargetIndex, hueOffset: self.nextRandomStep, response: selectedIndex)

        if self.comboArray.isEmpty {
            self.closeSession()
        } else {
            super.selected(selectedIndex)
            self.positionAndColorNodes(shuffle: true)
            self.trialCounter += 1
        }
    }
    
    override func closeSession() {
             
        for node in self.children {
            node.removeFromParent()
        }
        
        if let pathDirectory = getDocumentsDirectory() {
            let fileName = (experimentData.userInfo[.initials] ?? "untitled") + ".json"
            let filePath = pathDirectory.appendingPathComponent(fileName)
            let json = try? JSONEncoder().encode(experimentData)
            
            do {
                try json!.write(to: filePath)
                self.exitDelegate?.closeSessions(filePath)
            } catch {
                self.exitDelegate?.closeSessions(nil)
            }
        }
    }

    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
}


class ExperimentData: Codable {
    let userInfo: [ExperimentProperty: String]
    private var trialNumbers: [Int]
    private var hueOffsets: [Int]
    private var targetHues: [Int]
    private var trialResponses: [Int]
    
    init(_ userInfo: [ExperimentProperty: String]) {
        self.userInfo = userInfo
        self.trialNumbers = [Int]()
        self.targetHues = [Int]()
        self.hueOffsets = [Int]()
        self.trialResponses = [Int]()
    }
    
    func addTrial(number: Int, targetHue: Int, hueOffset: Int, response: Int) {
        if (trialNumbers.count == hueOffsets.count && trialNumbers.count == trialResponses.count && trialNumbers.count == targetHues.count) {
            self.trialNumbers.append(number)
            self.targetHues.append(targetHue)
            self.trialResponses.append(response)
            self.hueOffsets.append(hueOffset)
        } else {
            fatalError("Crucial Data Collection Error")
        }
    }
    
}

