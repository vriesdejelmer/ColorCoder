//
//  ExperimentData.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 03/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import UIKit

class ExperimentData: Codable {
    
    var targetSteps: Int
    var nodeSteps: Int
    var nodeOrdering: NodeOrdering
    var backgroundShade: CGFloat
    var centerDistance: CGFloat
    var stimulusDiameter: CGFloat
    var screenOrientation: ScreenOrientation
    var appVersion: String
    var deviceType: String
    
    private var trialNumbers = [Int]()
    private var nodeOffsets = [Int]()
    private var nodeOrderings = [[Int]]()
    private var targetOffsets = [Int]()
    private var trialResponses = [Int]()
    private var trialTimes = [Double]()
    private var leftRotations = [Bool]()
    
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
    
    init(_ expInfo: [ExperimentParameter: String], appVersion: String, deviceType: String) {
        if let version = expInfo[.version] {
            self.version = Int(version)!
        } else {
            self.version = 0
        }
        self.appVersion = appVersion
        self.deviceType = deviceType
        self.initials = expInfo[.initials]!
        self.targetSteps = Int(expInfo[.targetSteps]!)!
        self.nodeOrdering = NodeOrdering(rawValue: expInfo[.nodeOrdering]!)!
        self.nodeSteps = Int(expInfo[.nodeSteps]!)!
        self.backgroundShade = Double(expInfo[.backgroundShade]!).map{ CGFloat($0) }!
        self.centerDistance = Double(expInfo[.nodeEccentricity]!).map{ CGFloat($0) }!
        self.stimulusDiameter = Double(expInfo[.nodeDiameter]!).map{ CGFloat($0) }!
        self.stimulusDiameter = Double(expInfo[.nodeDiameter]!).map{ CGFloat($0) }!
        self.screenOrientation = ScreenOrientation(rawValue: expInfo[.screenOrientation]!)!
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
    
    func addTrial(number: Int, targetOffset: Int, nodeOffset: Int, trialTime: Double, response: Int, leftRotation: Bool, ordering: [Int]) {
        
        if (trialNumbers.count == nodeOffsets.count && trialNumbers.count == trialResponses.count && trialNumbers.count == targetOffsets.count) {
            self.trialNumbers.append(number)
            self.targetOffsets.append(targetOffset)
            self.trialResponses.append(response)
            self.nodeOffsets.append(nodeOffset)
            self.trialTimes.append(trialTime)
            self.leftRotations.append(leftRotation)
            self.nodeOrderings.append(ordering)
        } else {
            fatalError("Crucial Data Collection Error")
        }
    }
    
    
}

struct TrialParam: Codable {
    let nodeStep: Int
    let targetStep: Int
}
