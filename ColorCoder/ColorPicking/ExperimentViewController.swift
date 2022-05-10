//
//  GameViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit
import SpriteKit

public enum ExperimentMode {
    case practice, experiment
}

class ExperimentViewController: SubCompViewController, ExitDelegate {

    var gameView: SKView!
    var colorScore: UILabel!
    let trialPrefix = "Trial: "
    let trialFont = "LLPixel"
    var experimentMode: ExperimentMode!
    weak var dataDelegate: DataDelegate?
    var userProfile: UserProfile?
    var experimentData: ExperimentData?
    var alert: UIAlertController?
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGameView()
        
        if self.experimentMode == .practice {
            self.addLabels()
        }
        self.createGameScene()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIScreen.main.brightness = CGFloat(0.69) //Hacky, but this seems to ensure it works
        UIScreen.main.brightness = CGFloat(0.7) //Should work best in viewDidAppear
        self.showInstructions()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let expScene = self.scene as? ExperimentScene {
            self.dataDelegate?.saveProgress(expScene.experimentData)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func setupGameView() {
        self.gameView   = SKView()
        if self.experimentMode == .practice {
            self.gameView.layer.cornerRadius    = 5
            self.gameView.layer.borderColor     = UIColor.gray.cgColor
            self.gameView.layer.borderWidth     = 2
        }
        
        self.gameView.translatesAutoresizingMaskIntoConstraints = false

        addViewWithInsets(self.gameView, superView: self.view, insets: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        self.view.sendSubviewToBack(self.gameView)
    }

    func addLabels() {
        self.colorScore = self.addTrialLabel(with: trialPrefix + "0")
        
        addEqualityConstraints(colorScore, superView: self.view, for: [.top, .left], offsets: [0, 16])
    }

    func addTrialLabel(with text: String) -> UILabel {
        let trialLabel     = UILabel()
        trialLabel.textColor = UIColor(white: GeneralSettings.backgroundGray + 0.5, alpha: 1.0)
        trialLabel.text    = text
        trialLabel.font    = UIFont(name: trialFont, size: 32)
        trialLabel.translatesAutoresizingMaskIntoConstraints  = false
        trialLabel.sizeToFit()
        addHeightConstraint(50, to: trialLabel)
        self.view.addSubview(trialLabel)
        return trialLabel
    }

    func createGameScene() {
        let screenRect  = UIScreen.main.fixedCoordinateSpace.bounds

        if self.experimentMode == .practice {
            self.scene = PracticeScene(size: view.bounds.size)
            
        } else {
            self.scene = ExperimentScene(size: view.bounds.size)
            if let expData = self.experimentData {
                (self.scene as! ExperimentScene).experimentData = expData
                (self.scene as! ExperimentScene).dataDelegate = self.dataDelegate
            }
        }
         
        self.scene.displayDelegate = self
        self.scene.exitDelegate = self
        self.scene.setOrientation(to: screenRect.size)
        self.gameView.ignoresSiblingOrder   = true
        self.scene.scaleMode                     = .resizeFill
        self.view.backgroundColor           = GeneralSettings.backgroundColor
        self.gameView.presentScene(self.scene)

    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }
    
    func closeSession() {
        self.showAlert(with: "Experiment Complete", message: "You have completed the experiment, thank you for your participation", buttonText: "Finally!", isDismissing: true)
    }
  
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        self.displayWarningIfNeeded()
    }
    
    func displayWarningIfNeeded() {
        if self.experimentMode == .experiment, let expData = self.experimentData {
            let orientation = UIDevice.current.orientation
            if expData.screenOrientation == .horizontal {
                if !(orientation == .landscapeLeft || orientation == .landscapeRight) {
                    self.displayOrientationWarning(expData.screenOrientation)
                } else {
                    self.removeOrientationWarning()
                }
            } else {
                if !(orientation == .portrait || orientation == .portraitUpsideDown) {
                    self.displayOrientationWarning(expData.screenOrientation)
                } else {
                    self.removeOrientationWarning()
                }
            }
        }
    }
    
    func displayOrientationWarning(_ orientation: ScreenOrientation) {
        if alert == nil {
            self.alert = UIAlertController(title: "Wrong Orientation", message: "The Experiment should be performed whilest keeping the ipad in \(orientation.longName) mode, please rotate the ipad correctly", preferredStyle: .alert )
            self.present(self.alert!, animated: false)
        }
    }
    
    func removeOrientationWarning() {
        if let alert = self.alert {
            alert.dismiss(animated: false) {
                self.alert = nil
            }
        }
    }
    
}

extension ExperimentViewController: DisplayDelegate {

    func updateTrialCount(to score: Int) {
        self.colorScore.text = trialPrefix + String(score)
    }

    func showInstructions() {
        let instructionAlert = UIAlertController(title: "Instructions, Please Read", message: "Welcome to the experiment! Each trial starts upon placing the finger in the center ring, which will change in color. Upon this color change, please select, from the surroundings disks, the disk that is most similar (?) in color. While it is not important to be as fast as possible, please do not overthink and try to respond promptly.", preferredStyle: .alert)
        
        instructionAlert.addAction(UIAlertAction(title: "Let's Do It", style: .default) {_ in
            self.displayWarningIfNeeded()
        })
        self.present(instructionAlert, animated: true)
    }
    
    func displayProgress(trialNumber: Int, trialsLeft: Int) {
        self.showAlert(with: "Progress Report", message: "You have completed \(trialNumber) trials and have \(trialsLeft) trials left. You can take a break at any time by closing the game using the cross in the top right corner of the screen and restarting by going to the existing user tab and selecting your initials from the list", buttonText: "OK", isDismissing: false)
    }
    
}


public protocol ExitDelegate: AnyObject {
    func closeSession()
}

