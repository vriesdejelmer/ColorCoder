//
//  GeneralSettings.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

public class GeneralSettings {

    public static let defaults = UserDefaults.standard

    public struct DefaultParams {
        public static let progressTrials = 300
        public static let centerRingDiameter: CGFloat = 110
        public static let numberOfNodes = 7
        public static let centerRingWidth: CGFloat = 25
        public static let targetSteps = 35
        public static let nodeSteps = 35
        public static let brightness = 0.7
    }
    
    public struct Constants {
        public static let SegmentCell: String = "SegmentCell"
        public static let TextCell: String = "TextCell"
        public static let CoderNotInitialzed: String = "init(coder:) has not been implemented"
    }
    
    public static var backgroundGray: CGFloat {
        get { return CGFloat(defaults.float(forKey: SettingsKey.backgroundGray)) }
        set { defaults.set(Float(newValue), forKey: SettingsKey.backgroundGray) }
    }
    
    public static var backgroundColor: UIColor {
        get { return UIColor(white: CGFloat(defaults.float(forKey: SettingsKey.backgroundGray)), alpha: 1.0) }
    }
    
    public static var stimEccFactor: CGFloat {
        get { return CGFloat(defaults.float(forKey: SettingsKey.eccentricityFactor)) }
        set { defaults.set(Float(newValue), forKey: SettingsKey.eccentricityFactor) }
    }

    public static var nodeEccentricity: CGFloat {
        get { return CGFloat(defaults.float(forKey: SettingsKey.eccentricityFactor))*270+120 }
    }
    
    public static var nodeOrdering: NodeOrdering {
        set { defaults.set(newValue.rawValue, forKey: SettingsKey.nodeOrdering) }
        get {
            if let orderingString = defaults.string(forKey: SettingsKey.nodeOrdering), let nodeOrder = NodeOrdering(rawValue: orderingString) {
                return nodeOrder
            } else {
                return .shuffled
            }
        }
    }
    
    public static var screenRotation: ScreenOrientation {
        set { defaults.set(newValue.rawValue, forKey: SettingsKey.screenRotation) }
        get {
            if let orientationString = defaults.string(forKey: SettingsKey.screenRotation), let orientation = ScreenOrientation(rawValue: orientationString) {
                return orientation
            } else {
                return .vertical
            }
        }
    }
    
    
    public static var stimDiamFactor: CGFloat {
        get { return CGFloat(defaults.float(forKey: SettingsKey.sizeFactor)) }
        set { defaults.set(Float(newValue), forKey: SettingsKey.sizeFactor) }
    }
    
    public static var nodeDiameter: CGFloat {
        get { return CGFloat(defaults.float(forKey: SettingsKey.sizeFactor))*100+30 }
    }
    
    public static func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    public static let aboutText: String = "Unfortunately for those looking for a psychadelic version of Pong this app was created for the purpose of measuring eye movements and studying the possiblity of communicating eye movement behavior from one player to another."
    
}


//extend NSUserDefaults to accomodate colors
extension UserDefaults {

    public func colorForKey(_ key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            //color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
            do { try color = NSKeyedUnarchiver.unarchivedObject(ofClass:
                UIColor.self, from: colorData)
            } catch { return nil }
        }
        return color
    }

    public func setColor(_ color: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = color {
            do {
                try colorData = NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
                set(colorData, forKey: key)
            } catch {  }
            
        }

    }
}


public struct SettingsKey {
    public static let sizeFactor        = "SizeFactor"
    public static let eccentricityFactor         = "EccentricityFactor"
    public static let backgroundGray  = "BackgroundColor"
    public static let nodeOrdering = "NodeOrdering"
    public static let screenRotation = "ScreenRotation"
}

struct SegueIdentifier {
    static let settingsSegue    = "SettingsSegue"
}

public func hsv_to_rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> UIColor {
    
    if s == 0.0 {
        return UIColor(red: v, green: v, blue: v, alpha: 1.0)
    }
    var i = Int(h*6.0) //# XXX assume int() truncates!
    let f = (h*6.0) - CGFloat(i)
    let p = v*(1.0 - s)
    let q = v*(1.0 - s*f)
    let t = v*(1.0 - s*(1.0-f))
    i = i%6
    if i == 0 {
        return UIColor(red: v, green: t, blue: p, alpha: 1.0)
    }
    if i == 1 {
        return UIColor(red: q, green: v, blue: p, alpha: 1.0)
    }
    if i == 2 {
        return UIColor(red: p, green: v, blue: t, alpha: 1.0)
    }
    if i == 3 {
        return UIColor(red: p, green: q, blue: v, alpha: 1.0)
    }
    if i == 4 {
        return UIColor(red: t, green: p, blue: v, alpha: 1.0)
    }
    if i == 5 {
        return UIColor(red: v, green: p, blue: q, alpha: 1.0)
    }
    return .black
}

