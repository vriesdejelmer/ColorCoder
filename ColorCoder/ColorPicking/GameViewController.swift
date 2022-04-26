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

class GameViewController: SubCompViewController, ExitDelegate {

    var gameView: SKView!
    var colorScore: UILabel!
    let trialPrefix = "Trial: "
    let trialFont = "LLPixel"
    var activityVC: UIActivityViewController?
    var experimentMode: ExperimentMode!
    var userInfo: [ExperimentProperty: String]?
    var alert: UIAlertController?

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
        
        self.displayWarningIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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

        let scene: GameScene
        if self.experimentMode == .practice {
            scene = PracticeScene(size: view.bounds.size)
            (scene as! PracticeScene).viewDelegate = self
        } else {
            scene = ExperimentScene(size: view.bounds.size)
            if let userInfo = self.userInfo {
                (scene as! ExperimentScene).experimentData = ExperimentData(userInfo)
            }
        }
         
        scene.exitDelegate = self
        scene.setOrientation(to: screenRect.size)
        self.gameView.ignoresSiblingOrder   = true
        scene.scaleMode                     = .resizeFill
        self.view.backgroundColor           = GeneralSettings.backgroundColor
        self.gameView.presentScene(scene)

    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all
    }
    
    func closeSessions(_ fileURL: URL?) {

        if let url = fileURL {
            do {
                let _ = try Data(contentsOf: url)
                
                self.activityVC = UIActivityViewController(activityItems: ["Something", url], applicationActivities: nil)
                if let activityVC = activityVC {
                    activityVC.popoverPresentationController?.sourceView = self.gameView
                    activityVC.excludedActivityTypes = [.addToReadingList, .openInIBooks, .print, .copyToPasteboard]

                    activityVC.popoverPresentationController?.sourceRect = CGRect(origin: self.gameView.bounds.center, size: .zero)
                    activityVC.popoverPresentationController?.permittedArrowDirections = []
                    activityVC.completionWithItemsHandler = { [weak self] (_,_,_, error: Error?) in
                        self?.activityVC = nil
                        self?.dismiss(animated: true)
                    }
                    
                    self.present(activityVC, animated: true, completion: nil)
                }
                //
            } catch {
                self.dismiss(animated: true)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.activityVC?.popoverPresentationController?.sourceRect = CGRect(origin: self.gameView.center, size: .zero)
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        self.displayWarningIfNeeded()
    }
    
    func displayWarningIfNeeded() {
        if self.experimentMode == .experiment {
            let orientation = UIDevice.current.orientation
            if orientation != .landscapeLeft && orientation != .landscapeRight {
                self.alert = UIAlertController(title: "Wrong Orientation", message: "The Experiment should be performed whilest keeping the ipad in Landscape mode, please rotate the ipad correctly", preferredStyle: .alert )
                self.present(self.alert!, animated: true)
            } else {
                if let alert = self.alert {
                    alert.dismiss(animated: true)
                }
            }
        }
    }
    
}

public protocol ExitDelegate: AnyObject {
    func closeSessions(_ fileURL: URL?)
}

extension GameViewController: CoderViewContainer {
    func updateTrialCount(to score: Int) {
        self.colorScore.text = trialPrefix + String(score)
    }
}
