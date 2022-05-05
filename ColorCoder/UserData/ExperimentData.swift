//
//  ExperimentData.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 03/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import UIKit

class ExperimentData: Codable {
    
    private var targetSteps: Int
    private var nodeSteps: Int
    private var backgroundShade: CGFloat
    private var centerDistance: CGFloat
    private var stimulusDiameter: CGFloat
    
    private var elementLocations = [CGPoint]()
    private var trialNumbers = [Int]()
    private var nodeOffsets = [Int]()
    private var targetOffsets = [Int]()
    private var trialResponses = [Int]()
    private var trialTimes = [Double]()
    
    private var comboArray = [TrialParam]()
    
    var initials: String
    var version: Int
    var trialParam: TrialParam?
    var hasTrialsLeft: Bool {
        return !comboArray.isEmpty
    }
    var trialsLeft: Int {
        return comboArray.count
    }
    
    init(_ expInfo: [ExperimentParameter: String]) {
        self.version = 1
        self.initials = expInfo[.initials]!
        self.targetSteps = Int(expInfo[.targetSteps]!)!
        self.nodeSteps = Int(expInfo[.nodeSteps]!)!
        self.backgroundShade = Double(expInfo[.backgroundShade]!).map{ CGFloat($0) }!
        self.centerDistance = Double(expInfo[.nodeEccentricity]!).map{ CGFloat($0) }!
        self.stimulusDiameter = Double(expInfo[.nodeDiameter]!).map{ CGFloat($0) }!
        
        self.comboArray = self.createComboArray()
    }
    
    init(_ userProfile: UserProfile, version: Int, targetSteps: Int, nodeSteps: Int) {
        self.version = version
        self.initials = userProfile.initials
        self.targetSteps = targetSteps
        self.nodeSteps = nodeSteps
        self.backgroundShade = GeneralSettings.backgroundGray
        self.centerDistance = GeneralSettings.nodeEccentricity
        self.stimulusDiameter = GeneralSettings.nodeDiameter
        
        self.comboArray = self.createComboArray()
    }
    
    
    func createComboArray() -> [TrialParam] {
        let baseHueArray: [Int] = Array(0..<self.targetSteps)
        let nodeArray: [Int] = Array(0..<self.nodeSteps)

        let nodeSelection = Array(nodeArray.map({[Int](repeating: $0, count: baseHueArray.count)}).joined())
        let hueSelection = [Int](repeating: baseHueArray, count: self.nodeSteps)
        
        return zip(nodeSelection, hueSelection).map { TrialParam(nodeStep: $0, targetStep: $1) }
    }
    
    func getNextTrialParameters() -> TrialParam? {
        guard let index = self.comboArray.indices.randomElement() else { return nil }
        self.trialParam = self.comboArray.remove(at: index)
        return trialParam
    }
        
    func revertLastTrial() {
        if let lastParams = self.trialParam {
            self.comboArray.append(lastParams)
        }
    }
    
    func addTrial(number: Int, targetOffset: Int, nodeOffset: Int, trialTime: Double, response: Int) {
        if (trialNumbers.count == nodeOffsets.count && trialNumbers.count == trialResponses.count && trialNumbers.count == targetOffsets.count) {
            self.trialNumbers.append(number)
            self.targetOffsets.append(targetOffset)
            self.trialResponses.append(response)
            self.nodeOffsets.append(nodeOffset)
            self.trialTimes.append(trialTime)
        } else {
            fatalError("Crucial Data Collection Error")
        }
    }
    
    
}

struct TrialParam: Codable {
    let nodeStep: Int
    let targetStep: Int
}