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

enum ExperimentParameter: String {
    
    case age, initials, sex, targetSteps, nodeSteps, backgroundShade, nodeDiameter, nodeEccentricity, version, nodeOrdering, screenOrientation

    var displayName: String {
        switch self {
        case .age: return "Participant Age?"
        case .initials: return "Participant initials"
        case .sex: return "Participant sex?"
        case .targetSteps: return "Target Steps"
        case .nodeSteps: return "Node Steps"
        case .nodeEccentricity: return "Node Eccentricity"
        case .nodeDiameter: return "Node Diameter"
        case .backgroundShade: return "Background Grey Level"
        case .version: return "Version"
        case .nodeOrdering: return "Random Node Ordering"
        case .screenOrientation: return "Screen Orientation"
        }
    }
    
    var instruction: String {
        switch self {
        case .age: return "whole number 18, 19, 20, .."
        case .initials: return "(min 3 characters)"
        case .sex: return "(M, F, O)"
        case .targetSteps: return "number of target variations"
        case .nodeSteps: return "number of shifts in node hue"
        case .nodeEccentricity: return "node to center distance"
        case .nodeDiameter: return "node diameter"
        case .backgroundShade: return "background gray [0-1]"
        case .version: return "(shouldn't be set manually)"
        case .nodeOrdering: return "Node ordering (l-to-r or random)"
        case .screenOrientation: return "vertical or horizontal"
        }
    }
    
    func getCellType() -> InputCellType {
        if self == .nodeOrdering || self == .screenOrientation { return .switchCell }
        return .textCell
    }
}

