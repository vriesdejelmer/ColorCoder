//
//  ViewController.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 25/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController {

    let buttonList: [ControlItem] = [.practice, .run, .userProfiles, .settings]
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
        case .run: self.runExperiment()
        case .userProfiles: self.pushUPController()
        case .settings: self.pushSettingsController()
        }
    }
    
    func pushSettingsController() {
        let settingsController  = SettingsViewController()
        self.present(settingsController, animated: true, completion: nil)
    }

    func pushUPController() {
        let upController     = UserProfileController()
        upController.dataDelegate = self.dataManager
        let navController = UINavigationController(rootViewController: upController)
        self.present(navController, animated: true, completion: nil)
    }
}

extension MenuViewController: ExperimentRunDelegate {
    
    
    func pushGameController() {
        let gameController  = ExperimentViewController()
        gameController.experimentMode = .practice
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }

    func runExperiment() {
        let userEntryController = ExperimentEntryController()
        userEntryController.users = self.dataManager.getActiveUserProfiles()
        userEntryController.dataDelegate = dataManager
        userEntryController.runDelegate = self
        self.encapsulatingNC = UINavigationController(rootViewController: userEntryController)
        self.present(self.encapsulatingNC!, animated: true, completion: nil)
    }
                                                                      
    func startExperiment(_ expData: ExperimentData) {
        
        self.encapsulatingNC?.dismiss(animated: true)
        let gameController  = ExperimentViewController()
        gameController.experimentMode = .experiment
        gameController.experimentData = expData
        gameController.dataDelegate = self.dataManager
        gameController.modalPresentationStyle = .fullScreen
        self.present(gameController, animated: true, completion: nil)
    }
    
}

class ControlButton: UIButton {
    var controlItem: ControlItem!
}

enum ControlItem {
    case practice, run, settings, userProfiles

    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .run: return "Run Experiment"
        case .settings: return "Settings"
        case .userProfiles: return "User Profiles"
        }
    }

}

protocol ExperimentRunDelegate: AnyObject {
    func startExperiment(_ expData: ExperimentData)
}
