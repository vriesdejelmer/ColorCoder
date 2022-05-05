//
//  ViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 25/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController {

    let buttonList: [ControlItem] = [.practice, .play, .settings, .about]
    var dataManager: DataManager!
    var encapsulatingNC: UINavigationController?

    @IBOutlet weak var controlStack: UIStackView! {
        didSet {
            self.setupControlButtons()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataManager = DataManager()
    }

    func setupControlButtons() {
        for controlItem in buttonList {
            let controlButton = self.createButton(for: controlItem)
            self.controlStack.addArrangedSubview(controlButton)
        }
    }

    func createButton(for controlItem: ControlItem) -> UIButton {
        let button = ControlButton(type: .custom)
        button.setTitle(controlItem.displayName, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.controlItem          = controlItem
        button.translatesAutoresizingMaskIntoConstraints    = false
        addHeightConstraint(50, to: button)
        button.layer.borderColor    = UIColor.black.cgColor
        button.layer.cornerRadius   = 10
        button.layer.borderWidth    = 1.5
        button.addTarget(self, action: #selector(MenuViewController.buttonPressed(_:)), for: .touchUpInside)
        return button
    }

    @objc func buttonPressed(_ sender: ControlButton) {
        switch sender.controlItem! {
        case .practice: self.pushGameController()
        case .play: self.runExperiment()
        case .settings: self.pushSettingsController()
        case .about: self.pushAboutController()
        }
    }
    
    func pushSettingsController() {
        let settingsController  = SettingsViewController()
        self.present(settingsController, animated: true, completion: nil)
    }

    func pushAboutController() {
        let aboutController     = AboutViewController()
        self.present(aboutController, animated: true, completion: nil)
    }
}

extension MenuViewController: ExperimentRunDelegate {
    
    
    func pushGameController() {
        let gameController  = GameViewController()
        gameController.experimentMode = .practice
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }

    func runExperiment() {
        let tabbedController = UserSetupController()
        tabbedController.dataDelegate = dataManager
        tabbedController.activeUserProfiles = self.dataManager.getActiveUserProfiles()
        tabbedController.runDelegate = self
        self.encapsulatingNC = UINavigationController(rootViewController: tabbedController)
        self.present(self.encapsulatingNC!, animated: true, completion: nil)
    }
                                                                      
    func startExperiment(_ expInfo: [ExperimentParameter: String], isNewUser: Bool) {
        self.encapsulatingNC?.dismiss(animated: true)
        let gameController  = GameViewController()
        gameController.experimentMode = .experiment
        if isNewUser {
            gameController.userProfile = self.dataManager.createUserProfile(for: expInfo)
            gameController.experimentData = ExperimentData(expInfo)
        } else {
            if let userProfile = self.dataManager.getUserProfile(for: expInfo[.initials]!) {
                gameController.userProfile = userProfile
                gameController.experimentData = dataManager.loadExistingVersion(userProfile)
            }
        }
        
        gameController.dataDelegate = self.dataManager
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }
    
}

class ControlButton: UIButton {
    var controlItem: ControlItem!
}

enum ControlItem {
    case practice, play, settings, about

    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .play: return "Play"
        case .settings: return "Settings"
        case .about: return "About"
        }
    }

}

protocol ExperimentRunDelegate: AnyObject {
    func startExperiment(_ expInfo: [ExperimentParameter: String], isNewUser: Bool)
}
