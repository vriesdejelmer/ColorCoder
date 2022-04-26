//
//  DataStructs.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import Foundation

enum OrientationDirection {
    case horizontal, vertical
}

enum SettingsItem: String {
    case backgroundGray, eccentricityFactor, sizeFactor

    var displayName: String {
        switch self {
        case .sizeFactor: return "Size Factor"
        case .eccentricityFactor: return "Eccentricity"
        case .backgroundGray: return "Background Shade"
        }
    }
}


enum ExperimentProperty: String, Codable {
    
    case age, initials, sex, targetSteps, nodeSteps

    var displayName: String {
        switch self {
        case .age: return "Participant Age?"
        case .initials: return "Participant initials"
        case .sex: return "Participant sex?"
        case .targetSteps: return "Target Steps"
        case .nodeSteps: return "Node Steps"
        }
    }
    
    var instruction: String {
        switch self {
        case .age: return "whole number 18, 19, 20, .."
        case .initials: return "(min 3 characters)"
        case .sex: return "(M, F, O)"
        case .targetSteps: return "(experimenter only)"
        case .nodeSteps: return "(experimenter only)"
        }
    }
    
    var hasDefault: Bool {
        return self == .targetSteps || self == .nodeSteps
    }
    
    func getDefault() -> String {
        switch self {
        case .targetSteps: return "40"
        case .nodeSteps: return "30"
        default: return ""
        }
    }
}


public enum PaddleType: String, CaseIterable {
    
    case regularPaddle = "Regular", irregularPaddle = "Irregular", soapPaddle = "Soap"
    
}
